# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "stimulus-reveal-controller", to: "https://ga.jspm.io/npm:stimulus-reveal-controller@4.1.0/dist/stimulus-reveal-controller.mjs"
pin "slim-select", to: "https://ga.jspm.io/npm:slim-select@2.4.5/dist/slimselect.es.js"
pin "debounce", to: "https://ga.jspm.io/npm:debounce@1.2.1/index.js"
pin "tailwindcss-stimulus-components", to: "https://ga.jspm.io/npm:tailwindcss-stimulus-components@4.0.1/dist/tailwindcss-stimulus-components.module.js"