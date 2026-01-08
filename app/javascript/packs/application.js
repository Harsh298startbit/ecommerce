// Rails defaults
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// ----------------------------
// jQuery (MUST BE FIRST)
// ----------------------------
// Use npm jQuery for proper webpack compatibility with plugins
import $ from "jquery"
window.$ = $
window.jQuery = $

// Ensure jQuery is available to plugins
if (typeof window.jQuery === 'undefined') {
  throw new Error('jQuery failed to load!')
}

// ----------------------------
// Bootstrap and jQuery plugins (loaded at runtime so they see global jQuery)
// ----------------------------
require("../src/popper.min")
require("../src/bootstrap.min")

// jQuery plugins and files (ORDER MATTERS)
require("../src/jquery.easing.1.3")
require("../src/jquery.waypoints.min")
require("../src/jquery.stellar.min")
require("../src/jquery.animateNumber.min")
require("../src/jquery.magnific-popup.min")

// UI libraries - MUST come before main.js initialization
require("../src/owl.carousel.min")
window.AOS = require("../src/aos")
require("../src/scrollax.min")
require("../src/bootstrap-datepicker")
require("../src/google-map")
require("../src/range")

// Verify plugins loaded
console.log("jQuery version:", $.fn.jquery)
console.log("owlCarousel available:", typeof $.fn.owlCarousel === 'function')
console.log("waypoint available:", typeof $.fn.waypoint === 'function')

require("../src/main")

// ----------------------------
// Stripe Checkout
// ----------------------------
require("../src/stripe_checkout")

// ----------------------------
// Custom JS (LAST)
// ----------------------------
// import "../src/main"


