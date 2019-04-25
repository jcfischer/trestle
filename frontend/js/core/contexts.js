import $ from 'jquery'

import { triggerInit } from './events'

export function refreshContext (context) {
  var url = context.data('context')

  $.get(url, function (data) {
    context.html(data)
    triggerInit(context)
  })
}

export function refreshMainContext () {
  var context = $('.app-main[data-context]')
  refreshContext(context)
}
