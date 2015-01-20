Template.reserveDialog.events
  'click [data-action=reserveItem]': (e, tmpl) ->
    item = Session.get 'reserveItem'
    now = new Date()

    if $('#reserveRequestDate').val()
      #Error checking for the reserve date, if it exists.
      dateReserved = $('#reserveRequestDate').val()
      if new Date(dateReserved) < now
        $('#reserveRequestDate').parent().parent().addClass('has-error')
        Session.set "reserveError", "Reservation date must be after today."
      else if item.reservation.dateReserved and new Date(dateReserved) > item.reservation.dateReserved and new Date(dateReserved) < item.reservation.expectedReturn
        $('#reserveRequestDate').parent().parent().addClass('has-error')
        Session.set "reserveError", "Item is already reserved for that timeframe. Please select a different date."
      else
        Session.set "reserveError", null
        $('#reserveRequestDate').parent().parent().removeClass('has-error')

    else
      #If the field is empty, note that.
      $('#reserveRequestDate').parent().parent().addClass('has-error')
      Session.set "reserveError", "A request date is required."

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
    
    #Make sure we don't have any errors. Could also just check if reserveError is null.
    if tmpl.findAll('.has-error').length is 0
      Meteor.call 'reserveItem', item._id, reservation
      $('#reserveDialog').modal('toggle')

  'click [data-action=cancelReserve]': (e, tmpl) ->
    tmpl.$('.has-error').removeClass('has-error')
    Session.set "reserveError", null
    Session.set "reserveItem", null

  'keyup': (e, tmpl) ->
    if e.keyCode is 27
      ('#cancelButton').click()

Template.reserveDialog.rendered = ->
  $('#reserveReturnDate').datepicker()
  $('#reserveRequestDate').datepicker()

Template.reserveDialog.helpers
  item: -> Session.get "reserveItem"
  reserveError: -> Session.get "reserveError"
