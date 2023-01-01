import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-release"
export default class extends Controller {
  connect() {
  }

  ripped = (e) => {
    let ripped = e.currentTarget.getAttribute('data-ripped')
    // checks if ripped is true or false and changes it
    ripped === 'true' ? ripped = 'false' : ripped ='true'
    // gets id from data-ref attribute
    const id = e.currentTarget.getAttribute('data-ref')
    // fetches the url and changes the ripped attribute
    const url = `/releases/${id}/ripped`
    fetch(url, {
      method: 'GET',
    })
    // changes the data-ripped attribute to the new value
    e.currentTarget.setAttribute('data-ripped', ripped)

    e.currentTarget.classList.toggle('ripped')
  }
}
