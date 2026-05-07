import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "dot"]

  connect() {
    this.currentIndex = 0
    this.totalSlides = this.slideTargets.length
    if (this.totalSlides <= 1) return

    this.showSlide(0, -1)
    this.startAutoPlay()

    this.element.addEventListener("mouseenter", () => this.pauseAutoPlay())
    this.element.addEventListener("mouseleave", () => this.startAutoPlay())
  }

  disconnect() {
    this.pauseAutoPlay()
  }

  next() {
    const prevIndex = this.currentIndex
    this.currentIndex = (this.currentIndex + 1) % this.totalSlides
    this.showSlide(this.currentIndex, prevIndex)
    this.restartAutoPlay()
  }

  prev() {
    const prevIndex = this.currentIndex
    this.currentIndex = (this.currentIndex - 1 + this.totalSlides) % this.totalSlides
    this.showSlide(this.currentIndex, prevIndex)
    this.restartAutoPlay()
  }

  goToDot(event) {
    const prevIndex = this.currentIndex
    const index = parseInt(event.currentTarget.dataset.index, 10)
    if (index === this.currentIndex) return
    this.currentIndex = index
    this.showSlide(this.currentIndex, prevIndex)
    this.restartAutoPlay()
  }

  showSlide(index, prevIndex) {
    this.slideTargets.forEach((slide, i) => {
      slide.classList.remove("is-active", "slide-out-left")

      if (i === index) {
        slide.classList.add("is-active")
      } else if (i === prevIndex) {
        slide.classList.add("slide-out-left")
      }
    })
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("is-active", i === index)
    })
  }

  startAutoPlay() {
    this.pauseAutoPlay()
    this.timer = setInterval(() => this.next(), 5000)
  }

  pauseAutoPlay() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  restartAutoPlay() {
    this.startAutoPlay()
  }
}
