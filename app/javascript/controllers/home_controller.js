import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {

  static targets = ["loadingOverlay"]

  connect() {
    const height = document.body.scrollHeight
    this.loadingOverlayTarget.style.height = `${height}px`
    this.loadingOverlayTarget.style.visibility = "visible"
  }
}
