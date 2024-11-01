import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

// Connects to data-controller="slim"
export default class extends Controller {
  connect() {
    const customOptions = JSON.parse(this.element.dataset.slimOptions || "{}");
    
    const slimSettings = {
      select: this.element,
      settings: customOptions
    };
    
    // check if addable is present in customOptions
    if (customOptions.addable) {
      slimSettings.events = {
        addable: function (value) {
          return value;
        }
      };
    }
    
    new SlimSelect(slimSettings);
  }
}