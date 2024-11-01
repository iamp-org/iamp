import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    this.element.classList.remove("hidden")
  }

  close() {
    this.element.classList.add("hidden")
  }
}