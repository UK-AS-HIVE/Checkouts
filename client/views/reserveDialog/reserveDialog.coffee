Template.reserveDialog.events
  'click [data-action=reserveItem]': (e, tmpl) ->
    $('#reserveDialog').modal('toggle')
    item = Session.get 'reserveItem'
    if $('#reserveAssignedTo').val()
      assignedTo = $('#reserveAssignedTo').val()
    else
      assignedTo = Meteor.user().username
    dateReserved = new Date($('#reserveRequestDate').val())
    if $('#reserveExpectedReturn').val()
      expectedReturn = new Date($('#reserveExpectedReturn').val())
    else
      expectedReturn = null
    reservation = {
      dateReserved: dateReserved
      expectedReturn: expectedReturn
      assignedTo: assignedTo
    }
    Meteor.call 'reserveItem', item._id, reservation

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
