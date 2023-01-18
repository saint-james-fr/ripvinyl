import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-release"
export default class extends Controller {

  static targets = [ "image", "overlay", "ripLaterButton" ]
  connect() {
  }

  ripped = (e) => {
    let ripped = e.currentTarget.getAttribute('data-ripped')
    // checks if ripped is true or false and changes it
    ripped === 'true' ? ripped = 'false' : ripped ='true'
    // gets id from data-ref attribute
    const id = e.currentTarget.getAttribute('data-ref')
    // fetches the url and changes the ripped attribute on DB
    const url = `/releases/${id}/ripped`
    fetch(url, {
      method: 'GET',
    })
    // changes the data-ripped attribute to the new value
    e.currentTarget.setAttribute('data-ripped', ripped)
    e.currentTarget.classList.toggle('ripped')
    this.imageTarget.classList.toggle('image-ripped')
    this.overlayTarget.classList.toggle('overlay')
    if (this.ripLaterButtonTarget.classList.contains('rip_later_orange')) {
    this.ripLaterButtonTarget.classList.toggle('rip_later_orange')
    this.ripLaterButtonTarget.classList.add('d-none')
    }
  }

  ripLater = (e) => {
    // gets id from data-ref attribute
    const id = e.currentTarget.getAttribute('data-ref')
    console.log(id)
    // gets rip later attribute
    let ripLater = e.currentTarget.getAttribute('data-rip-later')
    e.currentTarget.setAttribute('data-rip-later', ripLater)
    const url = `/releases/${id}/rip_later`
    // fetches the url and changes the ripped attribute on DB
    fetch(url, {
      method: 'GET',
    })
    e.currentTarget.classList.toggle('rip_later_orange')
  }

}
