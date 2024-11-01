// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// custom action added to support redirect on successfull turbo form submit. See https://www.ducktypelabs.com/turbo-break-out-and-redirect/
import { Turbo } from "@hotwired/turbo-rails"
Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};