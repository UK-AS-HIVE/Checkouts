Template.reserveDialog.events
  'click [data-action=reserveItem]': (e, tmpl) ->
    $('#reserveDialog').modal('toggle')
    Meteor.call 'reserveItem', username, date
  'click #cancelButton': (e, tmpl) ->
    Session.set "reserveItem", null

  'keyup': (e, tmpl) ->
    if e.keyCode is 27
      ('#cancelButton').click()

Template.reserveDialog.rendered = ->
  $('#reserveReturnDate').datepicker()
  $('#reserveRequestDate').datepicker()

Template.reserveDialog.helpers
  item: -> Session.get "reserveItem"
