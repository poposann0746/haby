
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
      if (!response.ok) {
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
    const container = button.closest(".habit-item") || button.parentElement
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
    const container = button.closest(".habit-item") || button.parentElement
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
}
