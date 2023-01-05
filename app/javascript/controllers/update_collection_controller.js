import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="update-collection"
export default class extends Controller {
  static targets = ["loadingOverlay", "button"]

  connect() {
  }

  update() {
    const height = document.body.scrollHeight // get page height
    this.loadingOverlayTarget.style.height = `${height}px`  // set overlay height
    this.loadingOverlayTarget.style.visibility = "visible" // show overlay
    document.body.style.overflow = "hidden"; // disable scrolling
    const id = this.buttonTarget.dataset.id // get collection id
    const url = "/update_collection"
    fetch(url,
      {method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({id: id})
    })
    .then(response => location.reload()) // reload page
  }
}
