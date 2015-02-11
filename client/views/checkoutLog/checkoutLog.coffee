Template.checkoutLog.helpers
  item: -> Session.get "checkoutLogItem"

Template.checkoutLog.events
  'hidden.bs.modal #checkoutLog': (e, tmpl) ->
    Session.set "checkoutLogItem", null
