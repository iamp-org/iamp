import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // displays a flash message for a certain period of time
  connect() {
    const element = document.querySelector('.flash-msg');
    element.removeAttribute('hidden');
    element.classList.add('animate__animated', 'animate__fadeIn');
    
    setTimeout(() => {      
      this.dismiss();
    }, 4000);
  }

  // the cancel button was pressed or the timer has run down so the message will be removed
  dismiss() {
    this.element.classList.add('animate__animated', 'animate__fadeOut');    
    
    // wait for the animation fadeOut to end then remove the element
    this.element.addEventListener('animationend', () => {
      this.element.remove();
    });
  }
}