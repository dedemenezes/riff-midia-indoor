import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="clock"
export default class extends Controller {
  static targets = ["time", "date"]

  connect() {
    this.updateTime()
    this.interval = setInterval(() => {
      this.updateTime()
    }, 1000) // update every second
  }

  disconnect() {
    clearInterval(this.interval)
  }

  updateTime() {
    const now = new Date()
    const hours = now.getHours().toString().padStart(2, '0')
    const minutes = now.getMinutes().toString().padStart(2, '0')
    const formattedTime = `${hours}:${minutes}`

    if (this.hasTimeTarget) {
      this.timeTarget.textContent = formattedTime
    }

    if (this.hasDateTarget) {
      const options = { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' }
      const formattedDate = now.toLocaleDateString('pt-BR', options)
      this.dateTarget.textContent = formattedDate
    }
  }
}
