import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "dayLabel"]

  // 曜日定数
  static WEEKDAYS = [1, 2, 3, 4, 5]  // 月〜金
  static WEEKENDS = [0, 6]           // 日、土
  static ALL_DAYS = [0, 1, 2, 3, 4, 5, 6]

  connect() {
    this.updateState()
  }

  // 毎日をトグル（全選択/全解除）
  selectAll() {
    const allChecked = this.checkboxTargets.every(cb => cb.checked)
    this.checkboxTargets.forEach(cb => {
      cb.checked = !allChecked
    })
    this.updateState()
  }

  // 平日のみ選択
  selectWeekdays() {
    this.checkboxTargets.forEach(cb => {
      const dayValue = parseInt(cb.value, 10)
      cb.checked = this.constructor.WEEKDAYS.includes(dayValue)
    })
    this.updateState()
  }

  // 週末のみ選択
  selectWeekends() {
    this.checkboxTargets.forEach(cb => {
      const dayValue = parseInt(cb.value, 10)
      cb.checked = this.constructor.WEEKENDS.includes(dayValue)
    })
    this.updateState()
  }

  // チェック状態に応じてUIを更新
  updateState() {
    this.dayLabelTargets.forEach(label => {
      const checkbox = label.querySelector('input[type="checkbox"]')
      if (checkbox && checkbox.checked) {
        label.classList.add("is-selected")
      } else {
        label.classList.remove("is-selected")
      }
    })
  }
}
