Template.reserveDialog.events
  'click button[data-action=submit]': (e, tmpl) ->
    item = Session.get 'reserveItem'
    now = new Date()
    
    #Error checking for the reserve date.
    if tmpl.$('input[name=requestDate]').val()
      reqError = null
      dateReserved = new Date(tmpl.$('input[name=requestDate]').val())
      if dateReserved < now
        reqError = "Reservation date must be after today."
      else if item.reservation?.dateReserved and dateReserved > item.reservation?.dateReserved and item.reservation?.expectedReturn? < new Date(dateReserved)
        reqError = "Item is already reserved for that timeframe. Please select a different date."
      else if item.reservation?.dateReserved and dateReserved > item.reservation?.dateReserved
        reqError = "Item is already reserved after that date without an expected return date."

    #Reserve request date field is empty.
    else
      reqError = "A request date is required."

    #Error checking for the return date.
    if tmpl.$('input[name=returnDate]').val()
      retError = null
      expectedReturn = new Date(tmpl.$('input[name=returnDate]').val())
      if dateReserved >= expectedReturn
        retError = "Return date must be after request date."
    else
      retError = null
      expectedReturn = null
    
    #Error handling - manual DOM manipulation.
    if reqError
      tmpl.$('span[name=requestDate]').text(reqError).show()
      tmpl.$('input[name=requestDate]').parent().parent().addClass('has-error')
    else
      tmpl.$('input[name=requestDate]').parent().parent().removeClass('has-error')
      tmpl.$('span[name=requestDate]').hide()

    if retError
      tmpl.$('span[name=returnDate]').text(retError).show()
      tmpl.$('input[name=returnDate]').parent().parent().addClass('has-error')
    else
      tmpl.$('input[name=returnDate]').parent().parent().removeClass('has-error')
      tmpl.$('span[name=returnDate]').hide()

    if tmpl.findAll('.has-error').length is 0
      reservation = {
        dateReserved: dateReserved
        expectedReturn: expectedReturn
        assignedTo: Meteor.user().username
      }
      #If we've made it this far and have no errors, we still have to check that the assignedTo username is good. If it is, we call the reserve method in the callback.
      if tmpl.$('input[name=assignedTo]').val()
        reservation.assignedTo = tmpl.$('input[name=assignedTo]').val()
        Meteor.call 'checkUsername', tmpl.$('input[name=assignedTo]').val(), (err, res) ->
          if res
            Meteor.call 'reserveItem', item._id, reservation
          else
            tmpl.$('button[data-action=checkUsername]').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
            tmpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-remove"></span>')
            
      else
        Meteor.call 'reserveItem', item._id, reservation
        $('#reserveDialog').modal('hide')

  'click button[data-action=checkUsername]': (e, tmpl) ->
    unless tmpl.$('input[name=assignedTo]').val() is ""
      Meteor.call 'checkUsername', tmpl.$('input[name=assignedTo]').val(), (err, res) ->
        if res
          tmpl.$('input[name=assignedTo]').parent().parent().removeClass('has-error').addClass('has-success')
          tmpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-ok"></span>')
          tmpl.$('button[data-action=checkUsername]').removeClass('btn-danger').removeClass('btn-primary').addClass('btn-success')
        else
          tmpl.$('input[name=assignedTo]').parent().parent().removeClass('has-success').addClass('has-error')
          tmpl.$('button[data-action=checkUsername]').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
          tmpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-remove"></span>')

  'keyup': (e, tmpl) ->
    if e.keyCode is 13
      tmpl.$('button[data-action=submit]').click()
    if e.keyCode is 27
      $('#reserveDialog').modal('hide')

  'hidden.bs.modal #reserveDialog': (e, tmpl) ->
    Session.set "reserveItem", null
    tmpl.$('.has-error').removeClass('has-error')
    tmpl.$('.has-success').removeClass('has-success')
    tmpl.$(":input").val('')
    tmpl.$('button[data-action=checkUsername]').removeClass('btn-success').removeClass('btn-danger').addClass('btn-primary')
    tmpl.$('button[data-action=checkUsername]').html('Check Username')

Template.reserveDialog.rendered = ->
  this.$('input[name=returnDate]').datepicker()
  this.$('input[name=requestDate]').datepicker()

Template.reserveDialog.helpers
  item: -> Session.get "reserveItem"
  rootUrl: ->
    if Meteor.isCordova
      __meteor_runtime_config__.ROOT_URL.replace(/\/$/, '') + __meteor_runtime_config__.ROOT_URL_PATH_PREFIX
    else
      __meteor_runtime_config__.ROOT_URL.replace /\/$/, ''
  thumbnailUrl: ->
    item = Session.get "reserveItem"
    if item.imageId
      return FileRegistry.findOne({_id: item.imageId})?.thumbnail
    else
      return null
