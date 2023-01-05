import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="width-buttons"
export default class extends Controller {
  static targets = ['releasesIndex', 'releaseCard']

  connect() {
  }

  twoRows() {
    this.releasesIndexTarget.style.gridTemplateColumns = 'repeat(2, 1fr)'
    const arr1 = [...document.querySelectorAll('h2')] .forEach((h2) => {
      h2.style.fontSize = '25px'
    })
    const arr2 = [...document.querySelectorAll('h4')].forEach((h4) => {
      h4.style.fontSize = '20px'
    })
    this.releaseCardTargets.forEach((card) => {
      card.style.width = '100%'
    })
  }

  fourRows() {
    this.releasesIndexTarget.style.gridTemplateColumns = 'repeat(4, 1fr)'
    const arr1 = [...document.querySelectorAll('h2')] .forEach((h2) => {
      h2.style.fontSize = '18px'
    })
    const arr2 = [...document.querySelectorAll('h4')].forEach((h4) => {
      h4.style.fontSize = '16.2px'
    })
    this.releaseCardTargets.forEach((card) => {
      card.style.width = '100%'
    })
  }

  fiveRows() {
    this.releasesIndexTarget.style.gridTemplateColumns = 'repeat(5, 1fr)'
    const arr1 = [...document.querySelectorAll('h2')] .forEach((h2) => {
      h2.style.fontSize = '18px'
    })
    const arr2 = [...document.querySelectorAll('h4')].forEach((h4) => {
      h4.style.fontSize = '16.2px'
    })
    this.releaseCardTargets.forEach((card) => {
      card.style.width = '100%'
    })
  }

  eightRows() {
      this.releasesIndexTarget.style.gridTemplateColumns = 'repeat(8, 1fr)'
      const arr1 = [...document.querySelectorAll('h2')] .forEach((h2) => {
        h2.style.fontSize = '0.8rem'
      })
      const arr2 = [...document.querySelectorAll('h4')].forEach((h4) => {
        h4.style.fontSize = '0.7rem'
      })
      this.releaseCardTargets.forEach((card) => {
        card.style.width = 'calc(calc(100vw - 22vw) / 8)'
      })
  }
}
