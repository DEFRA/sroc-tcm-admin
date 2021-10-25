// The uglifier compressor cannot handle ES6 syntax so we disable the no-var rule since we cannot use `let` and `const`
/* eslint-disable no-var */

// To prevent StandardJS erroring on `history.back()`, we define history as a global:
/* global history */

var $ = window.$

$(document).on('turbolinks:load', function () {
  $('.back-link').on('click', function (ev) {
    ev.preventDefault()
    history.back()
  })
})
