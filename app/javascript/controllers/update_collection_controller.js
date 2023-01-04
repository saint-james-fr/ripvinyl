import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="update-collection"
export default class extends Controller {
  static targets = ["loadingOverlay"]

  connect() {
  }

  update() {
    const height = document.body.scrollHeight
    this.loadingOverlayTarget.style.height = `${height}px`
    this.loadingOverlayTarget.style.visibility = "visible"
    const url = "/update_collection"
    fetch(url, {
    method: 'GET',
    }).then(response => location.reload())
  }
}
