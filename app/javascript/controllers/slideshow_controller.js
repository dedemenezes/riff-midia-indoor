import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="slideshow"
export default class extends Controller {
  static targets = ["slide"];

  connect() {
    this.currentIndex = 0;
    this.intervalTime = 8000; // 8 seconds

    if (this.slideTargets.length > 1) {
      this.showSlide(this.currentIndex);
      this.startSlideshow();
    }
  }

  disconnect() {
    clearInterval(this.interval);
  }

  startSlideshow() {
    this.interval = setInterval(() => {
      this.nextSlide();
    }, this.intervalTime);
  }

  showSlide(index) {
    this.slideTargets.forEach((slide, i) => {
      slide.classList.toggle("active", i === index);
    });
  }

  nextSlide() {
    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length;
    this.showSlide(this.currentIndex);
  }
}
