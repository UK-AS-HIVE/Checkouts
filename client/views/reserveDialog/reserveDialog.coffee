resetDialog = (tmpl) ->
  Session.set "reserveError", null
  Session.set "reserveItem", null
  tmpl.$('.has-error').removeClass('has-error')
  tmpl.$('.has-success').removeClass('has-success')
  tmpl.$(":input").val('')
  $('#reserveCheckBtn').removeClass('btn-success').removeClass('btn-danger').addClass('btn-primary')
  $('#reserveCheckBtn').html('Check Username')
  $('#reserveDialog').modal('hide')

Template.reserveDialog.events
  'click #reserveSubmitBtn': (e, tmpl) ->
    #A whole lotta form validation in here. Kinda monolithic. Can we tighten this up?
    item = Session.get 'reserveItem'
    now = new Date()

    if $('#reserveRequestDate').val()
      #Error checking for the reserve date, if it exists.
      dateReserved = new Date($('#reserveRequestDate').val())
      if dateReserved < now
        $('#reserveRequestDate').parent().parent().addClass('has-error')
        Session.set "reserveRequestDateError", "Reservation date must be after today."
      else if item.reservation?.dateReserved and dateReserved > item.reservation?.dateReserved and item.reservation?.expectedReturn? < new Date(dateReserved)
        $('#reserveRequestDate').parent().parent().addClass('has-error')
        Session.set "reserveRequestDateError", "Item is already reserved for that timeframe. Please select a different date."
      else if item.reservation?.dateReserved and dateReserved > item.reservation?.dateReserved
        Session.set "reserveRequestDateError", "Item is already reserved after that date without an expected return date."
      else
        Session.set "reserveRequestDateError", null
        $('#reserveRequestDate').parent().parent().removeClass('has-error')
    else
      #Reserve request date field is empty.
      $('#reserveRequestDate').parent().parent().addClass('has-error')
      Session.set "reserveRequestDateError", "A request date is required."

    if $('#reserveExpectedReturn').val()
      expectedReturn = new Date($('#reserveExpectedReturn').val())
      if dateReserved >= expectedReturn
        Session.set "reserveReturnDateError", "Return date must be after request date."
    else
      expectedReturn = null
      

    if tmpl.findAll('.has-error').length is 0
      reservation = {
        dateReserved: dateReserved
        expectedReturn: expectedReturn
        assignedTo: Meteor.user().username
      }
      #If we've made it this far and have no errors, we still have to check that the assignedTo username is good. If it is, we call the reserve method in the callback.
      if $('#reserveAssignedTo').val()
        reservation.assignedTo = $('#reserveAssignedTo').val()
        Meteor.call 'checkUsername', $('#reserveAssignedTo').val(), (err, res) ->
          if res
            Meteor.call 'reserveItem', item._id, reservation
            resetDialog(tmpl)
          else
            $('#reserveCheckBtn').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
            $('#reserveCheckBtn').html('<span class="glyphicon glyphicon-remove"></span>')
            
      else
        Meteor.call 'reserveItem', item._id, reservation
        $('#reserveDialog').modal('hide')

  'click #reserveCancelBtn': (e, tmpl) ->
    resetDialog(tmpl)

  'click #reserveCheckBtn': (e, tmpl) ->
    unless $('#reserveAssignedTo').val() is ""
      Meteor.call 'checkUsername', $('#reserveAssignedTo').val(), (err, res) ->
        if res
          $('#reserveAssignedTo').parent().parent().removeClass('has-error').addClass('has-success')
          $('#reserveCheckBtn').html('<span class="glyphicon glyphicon-ok"></span>')
          $('#reserveCheckBtn').removeClass('btn-danger').removeClass('btn-primary').addClass('btn-success')
        else
          $('#reserveAssignedTo').parent().parent().removeClass('has-success').addClass('has-error')
          $('#reserveCheckBtn').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
          $('#reserveCheckBtn').html('<span class="glyphicon glyphicon-remove"></span>')

  'keyup': (e, tmpl) ->
    if e.keyCode is 13
      tmpl.find('reserveSubmitBtn').click()
    if e.keyCode is 27
      tmpl.find('reserveCancelBtn').click()

Template.reserveDialog.rendered = ->
  $('#reserveReturnDate').datepicker()
  $('#reserveRequestDate').datepicker()

Template.reserveDialog.helpers
  item: -> Session.get "reserveItem"
  reserveRequestDateError: -> Session.get "reserveRequestDateError"
