import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select"
// For dynamic/dependent form fields
// Usage: e.g. {data: {action: "change->select#submit"}} within select field and {data: { controller: "select" }} on the form
export default class extends Controller {
  submit() {
    const formData = new FormData(this.element);
    const params = new URLSearchParams(formData).toString();
    fetch(`${this.element.action}?${params}`, {
      method: this.element.method,
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
    .then(r => r.text())
    .then(html => Turbo.renderStreamMessage(html))
  }
}