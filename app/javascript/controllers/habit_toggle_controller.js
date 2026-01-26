
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    url: String
  }

  initialize() {
    this.isSubmitting = false
  }

  async toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isSubmitting) return

    const button = this.buttonTarget
    const wasOn = button.classList.contains("is-on")

    this.isSubmitting = true

    // 即座にUIを更新（オプティミスティック更新）
    button.classList.toggle("is-on")
    button.setAttribute("aria-pressed", !wasOn)

    // ONになる場合のみアニメーションを発火
    if (!wasOn) {
      this.playSuccessAnimation(button)
    }

    try {
      const response = await this.submitRequest()
      if (response.ok) {
        // 成功した場合、今日の習慣画面ならセクション間移動
        this.moveItemBetweenSections(button, !wasOn)
      } else {
        // 失敗した場合は状態を戻す
        button.classList.toggle("is-on")
        button.setAttribute("aria-pressed", wasOn)
      }
    } catch (error) {
      // エラー時も状態を戻す
      button.classList.toggle("is-on")
      button.setAttribute("aria-pressed", wasOn)
      console.error("Toggle request failed:", error)
    } finally {
      // 必ず送信中フラグを解除
      this.isSubmitting = false
    }
  }

  async submitRequest() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    return fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      credentials: "same-origin"
    })
  }

  playSuccessAnimation(button) {
    // ボタンのパルスアニメーション
    button.classList.add("toggle-success")

    // パーティクル（紙吹雪）エフェクトを生成
    this.createParticles(button)

    // チェックマークアニメーション
    this.showCheckmark(button)

    // アニメーション終了後にクラスを削除
    setTimeout(() => {
      button.classList.remove("toggle-success")
    }, 600)
  }

  createParticles(button) {
    const container = button.closest(".habit-item, .todays-habit-item") || button.parentElement
    if (!container) return

    const rect = button.getBoundingClientRect()
    const containerRect = container.getBoundingClientRect()

    const colors = ["#f78257", "#117BBF", "#6AACB0", "#FFD700", "#FF6B6B"]
    const particleCount = 12

    for (let i = 0; i < particleCount; i++) {
      const particle = document.createElement("span")
      particle.className = "habit-particle"

      // ランダムな色とサイズ
      particle.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)]
      particle.style.width = `${Math.random() * 6 + 4}px`
      particle.style.height = particle.style.width

      // ボタンの中心からの位置
      const centerX = rect.left - containerRect.left + rect.width / 2
      const centerY = rect.top - containerRect.top + rect.height / 2
      particle.style.left = `${centerX}px`
      particle.style.top = `${centerY}px`

      // ランダムな方向への移動
      const angle = (Math.PI * 2 * i) / particleCount + (Math.random() - 0.5) * 0.5
      const distance = 40 + Math.random() * 30
      particle.style.setProperty("--tx", `${Math.cos(angle) * distance}px`)
      particle.style.setProperty("--ty", `${Math.sin(angle) * distance}px`)

      container.appendChild(particle)

      // アニメーション終了後に削除
      setTimeout(() => particle.remove(), 700)
    }
  }

  showCheckmark(button) {
    const container = button.closest(".habit-item, .todays-habit-item") || button.parentElement
    if (!container) return

    const checkmark = document.createElement("span")
    checkmark.className = "habit-checkmark"
    checkmark.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="20 6 9 17 4 12"></polyline>
      </svg>
    `

    const rect = button.getBoundingClientRect()
    const containerRect = container.getBoundingClientRect()

    checkmark.style.left = `${rect.left - containerRect.left + rect.width / 2}px`
    checkmark.style.top = `${rect.top - containerRect.top + rect.height / 2}px`

    container.appendChild(checkmark)

    setTimeout(() => checkmark.remove(), 800)
  }

  moveItemBetweenSections(button, isNowCompleted) {
    const item = button.closest(".todays-habit-item")
    if (!item) return // 今日の習慣画面以外では何もしない

    const page = document.querySelector(".todays-habits-page")
    if (!page) return

    // アニメーション後に移動
    setTimeout(() => {
      if (isNowCompleted) {
        this.moveToCompletedSection(item)
      } else {
        this.moveToIncompleteSection(item)
      }
      this.updateSectionCounts()
      this.updateCompleteMessage()
    }, 300)
  }

  moveToCompletedSection(item) {
    let completedSection = document.querySelector(".todays-habits-section--completed")

    // 完了セクションがなければ作成
    if (!completedSection) {
      completedSection = this.createCompletedSection()
      const container = document.querySelector(".todays-habits-container")
      const incompleteSection = document.querySelector(".todays-habits-section:not(.todays-habits-section--completed)")
      if (incompleteSection) {
        incompleteSection.after(completedSection)
      } else {
        container.appendChild(completedSection)
      }
    }

    const list = completedSection.querySelector(".todays-habits-list")

    // アイテムのスタイルを完了状態に更新
    item.classList.add("todays-habit-item--completed")

    // フェードアウト→移動→フェードイン
    item.style.opacity = "0"
    item.style.transform = "translateX(20px)"

    setTimeout(() => {
      list.appendChild(item)
      requestAnimationFrame(() => {
        item.style.transition = "opacity 0.3s ease, transform 0.3s ease"
        item.style.opacity = "1"
        item.style.transform = "translateX(0)"
      })
    }, 150)

    // 未完了セクションが空になったら非表示
    this.hideEmptyIncompleteSection()
  }

  moveToIncompleteSection(item) {
    let incompleteSection = document.querySelector(".todays-habits-section:not(.todays-habits-section--completed)")

    // 未完了セクションがなければ作成
    if (!incompleteSection) {
      incompleteSection = this.createIncompleteSection()
      const container = document.querySelector(".todays-habits-container")
      const hero = document.querySelector(".todays-habits-hero")
      if (hero) {
        hero.after(incompleteSection)
      } else {
        container.prepend(incompleteSection)
      }
    }

    const list = incompleteSection.querySelector(".todays-habits-list")

    // アイテムのスタイルを未完了状態に更新
    item.classList.remove("todays-habit-item--completed")

    // フェードアウト→移動→フェードイン
    item.style.opacity = "0"
    item.style.transform = "translateX(-20px)"

    setTimeout(() => {
      list.appendChild(item)
      requestAnimationFrame(() => {
        item.style.transition = "opacity 0.3s ease, transform 0.3s ease"
        item.style.opacity = "1"
        item.style.transform = "translateX(0)"
      })
    }, 150)

    // 完了セクションが空になったら非表示
    this.hideEmptyCompletedSection()
  }

  createCompletedSection() {
    const section = document.createElement("section")
    section.className = "todays-habits-section todays-habits-section--completed"
    section.innerHTML = `
      <h2 class="todays-habits-section__title">
        <span class="todays-habits-section__icon todays-habits-section__icon--completed">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
          </svg>
        </span>
        完了済み
        <span class="todays-habits-section__count">(0件)</span>
      </h2>
      <div class="todays-habits-list"></div>
    `
    return section
  }

  createIncompleteSection() {
    const section = document.createElement("section")
    section.className = "todays-habits-section"
    section.innerHTML = `
      <h2 class="todays-habits-section__title">
        <span class="todays-habits-section__icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
          </svg>
        </span>
        未完了
        <span class="todays-habits-section__count">(0件)</span>
      </h2>
      <div class="todays-habits-list"></div>
    `
    return section
  }

  hideEmptyIncompleteSection() {
    const section = document.querySelector(".todays-habits-section:not(.todays-habits-section--completed)")
    if (section) {
      const items = section.querySelectorAll(".todays-habit-item")
      if (items.length === 0) {
        section.remove()
      }
    }
  }

  hideEmptyCompletedSection() {
    const section = document.querySelector(".todays-habits-section--completed")
    if (section) {
      const items = section.querySelectorAll(".todays-habit-item")
      if (items.length === 0) {
        section.remove()
      }
    }
  }

  updateSectionCounts() {
    const incompleteSection = document.querySelector(".todays-habits-section:not(.todays-habits-section--completed)")
    const completedSection = document.querySelector(".todays-habits-section--completed")

    if (incompleteSection) {
      const count = incompleteSection.querySelectorAll(".todays-habit-item").length
      const countEl = incompleteSection.querySelector(".todays-habits-section__count")
      if (countEl) countEl.textContent = `(${count}件)`
    }

    if (completedSection) {
      const count = completedSection.querySelectorAll(".todays-habit-item").length
      const countEl = completedSection.querySelector(".todays-habits-section__count")
      if (countEl) countEl.textContent = `(${count}件)`
    }
  }

  updateCompleteMessage() {
    const incompleteSection = document.querySelector(".todays-habits-section:not(.todays-habits-section--completed)")
    const completedSection = document.querySelector(".todays-habits-section--completed")
    let completeMessage = document.querySelector(".todays-habits-complete-message")

    const hasIncomplete = incompleteSection && incompleteSection.querySelectorAll(".todays-habit-item").length > 0
    const hasCompleted = completedSection && completedSection.querySelectorAll(".todays-habit-item").length > 0

    // 全完了の場合、メッセージを表示
    if (!hasIncomplete && hasCompleted) {
      if (!completeMessage) {
        completeMessage = document.createElement("section")
        completeMessage.className = "todays-habits-complete-message"
        completeMessage.innerHTML = `
          <div class="todays-habits-complete-message__icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
              <polyline points="22 4 12 14.01 9 11.01"></polyline>
            </svg>
          </div>
          <p class="todays-habits-complete-message__text">今日の習慣をすべて達成しました！</p>
        `
        const container = document.querySelector(".todays-habits-container")
        if (completedSection) {
          completedSection.after(completeMessage)
        } else {
          container.appendChild(completeMessage)
        }
      }
    } else {
      // 未完了がある場合、メッセージを削除
      if (completeMessage) {
        completeMessage.remove()
      }
    }
  }
}
