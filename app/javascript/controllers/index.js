// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// https://www.stimulus-components.com/docs/stimulus-reveal-controller
import Reveal from 'stimulus-reveal-controller' 
application.register('reveal', Reveal) 

// https://github.com/excid3/tailwindcss-stimulus-components#tabs
import { Tabs } from "tailwindcss-stimulus-components"
application.register('tabs', Tabs)

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
