import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "progress", "progressBar"]

  // 300ms以内の遷移ではオーバーレイを表示しない
  static DELAY = 300
  // 10秒でタイムアウト
  static TIMEOUT = 10000

  connect() {
    this.delayTimer = null
    this.timeoutTimer = null
    this.activeSubmitButton = null

    this.handleFetchStart = this.handleFetchStart.bind(this)
    this.handleFetchEnd = this.handleFetchEnd.bind(this)
    this.handleLoad = this.handleLoad.bind(this)
    this.handleSubmitStart = this.handleSubmitStart.bind(this)
    this.handleSubmitEnd = this.handleSubmitEnd.bind(this)

    document.addEventListener("turbo:before-fetch-request", this.handleFetchStart)
    document.addEventListener("turbo:before-fetch-response", this.handleFetchEnd)
    document.addEventListener("turbo:load", this.handleLoad)
    document.addEventListener("turbo:submit-start", this.handleSubmitStart)
    document.addEventListener("turbo:submit-end", this.handleSubmitEnd)
  }

  disconnect() {
    this.clearTimers()
    document.removeEventListener("turbo:before-fetch-request", this.handleFetchStart)
    document.removeEventListener("turbo:before-fetch-response", this.handleFetchEnd)
    document.removeEventListener("turbo:load", this.handleLoad)
    document.removeEventListener("turbo:submit-start", this.handleSubmitStart)
    document.removeEventListener("turbo:submit-end", this.handleSubmitEnd)
  }

  //　ページ遷移ローディング

  handleFetchStart(event) {
    // フォーム送信はプログレスバーで対応するため除外
    if (event.target.tagName === "FORM") return
    // habit-toggleのfetchリクエストも除外
    if (event.target.closest && event.target.closest("[data-controller='habit-toggle']")) return

    this.delayTimer = setTimeout(() => {
      this.showOverlay()
    }, this.constructor.DELAY)
  }

  handleFetchEnd() {
    this.hideOverlay()
  }

  handleLoad() {
    // ページ読み込み完了時に確実に非表示にする（フォールバック）
    this.hideOverlay()
  }

  showOverlay() {
    if (!this.hasOverlayTarget) return
    this.overlayTarget.classList.add("is-visible")

    // タイムアウト安全策
    this.timeoutTimer = setTimeout(() => {
      this.hideOverlay()
    }, this.constructor.TIMEOUT)
  }

  hideOverlay() {
    this.clearTimers()
    if (!this.hasOverlayTarget) return
    this.overlayTarget.classList.remove("is-visible")
  }

  //　フォーム送信ローディング

  handleSubmitStart(event) {
    const form = event.target
    if (!form) return

    // プログレスバー表示
    this.showProgress()

    // 送信ボタンをdisabled化 + スピナー追加
    const submitButton = form.querySelector("[type='submit']")
    if (submitButton) {
      this.activeSubmitButton = submitButton
      submitButton.setAttribute("data-loading-submitting", "")
      submitButton.disabled = true

      const loadingText = submitButton.getAttribute("data-loading-text") || "送信中..."
      submitButton.dataset.originalText = submitButton.innerHTML
      submitButton.innerHTML = `<span class="loading-btn-spinner"></span>${loadingText}`
    }
  }

  handleSubmitEnd() {
    this.finishProgress()
    this.restoreSubmitButton()
  }

  showProgress() {
    if (!this.hasProgressTarget) return
    const progress = this.progressTarget
    const bar = this.progressBarTarget

    // リセット
    progress.classList.remove("is-finishing")
    bar.style.width = ""
    progress.classList.add("is-visible", "is-running")
  }

  finishProgress() {
    if (!this.hasProgressTarget) return
    const progress = this.progressTarget

    progress.classList.remove("is-running")
    progress.classList.add("is-finishing")

    // バーが100%に到達した後にフェードアウト
    setTimeout(() => {
      progress.classList.remove("is-visible", "is-finishing")
    }, 400)
  }

  restoreSubmitButton() {
    const button = this.activeSubmitButton
    if (!button) return

    button.removeAttribute("data-loading-submitting")
    button.disabled = false
    if (button.dataset.originalText) {
      button.innerHTML = button.dataset.originalText
      delete button.dataset.originalText
    }
    this.activeSubmitButton = null
  }

  //　ユーティリティ

  clearTimers() {
    if (this.delayTimer) {
      clearTimeout(this.delayTimer)
      this.delayTimer = null
    }
    if (this.timeoutTimer) {
      clearTimeout(this.timeoutTimer)
      this.timeoutTimer = null
    }
  }
}
