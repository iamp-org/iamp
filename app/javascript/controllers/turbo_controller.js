import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="turbo"
// For implementing modals, based on https://www.driftingruby.com/episodes/hotwire-modals
export default class extends Controller {
  initialize() {
    this.element.setAttribute("data-action", "click->turbo#click")
  }

  click(e) {
    e.preventDefault()
    this.url = this.element.getAttribute("href")
    fetch(this.url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
    .then(r => r.text())
    .then(html => Turbo.renderStreamMessage(html))
  }
}