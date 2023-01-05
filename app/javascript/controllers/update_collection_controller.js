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
    console.log(id)
    const url = "/update_collection?" + new URLSearchParams({id: id})
    console.log(url)
    fetch(url, {method: 'GET'}).then(response => location.reload()) // reload page
  }
}
