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
      const weekday = now.toLocaleDateString('pt-BR', { weekday: 'long' })
      const month   = now.toLocaleDateString('pt-BR', { month: 'long' })
      const day     = now.toLocaleDateString('pt-BR', { day: '2-digit' })
      const year    = now.toLocaleDateString('pt-BR', { year: 'numeric' })

      const capitalize = str => str.charAt(0).toUpperCase() + str.slice(1)

      const formattedDate = `${capitalize(weekday)}, ${day} de ${capitalize(month)} de ${year}`
      this.dateTarget.textContent = formattedDate
    }


  }
}
