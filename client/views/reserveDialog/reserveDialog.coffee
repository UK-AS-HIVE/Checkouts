Template.reserveDialog.events
  'click [data-action=reserveItem]': (e, tmpl) ->
    item = Session.get 'reserveItem'
    if $('#reserveRequestDate').val()
      #Since our input fields are in a div for the column width, we need the parent of that div for the error class.
      dateReserved = new Date($('#reserveRequestDate').val())
      $('#reserveRequestDate').parent().parent().removeClass('has-error')
    else
      $('#reserveRequestDate').parent().parent().addClass('has-error')
    if $('#reserveAssignedTo').val()
      assignedTo = $('#reserveAssignedTo').val()
    else
      assignedTo = Meteor.user().username

    if $('#reserveExpectedReturn').val()
      expectedReturn = new Date($('#reserveExpectedReturn').val())
    else
      expectedReturn = null
    reservation = {
      dateReserved: dateReserved
      expectedReturn: expectedReturn
      assignedTo: assignedTo
    }
    if tmpl.findAll('.has-error').length is 0
      Meteor.call 'reserveItem', item._id, reservation
      $('#reserveDialog').modal('toggle')
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
