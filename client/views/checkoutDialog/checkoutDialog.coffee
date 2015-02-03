resetCheckoutDialog = (tmpl) ->
  tmpl.$('.has-error').removeClass('has-error')
  tmpl.$('.has-success').removeClass('has-success')
  Session.set "checkoutError", null
  Session.set "checkoutItem", null
  Session.set "checkoutAssignedToError", null
  Session.set "checkoutExpectedReturnError", null
  tmpl.$('button[data-action=checkUsername]').addClass('btn-primary').removeClass('btn-success').removeClass('btn-danger')
  tmpl.$('button[data-action=checkUsername]').html('Check Username')
  tmpl.$('input[name=assignedTo]').val('')
  tmpl.$('input[name=returnDate]').val('')
  $('#checkoutDialog').modal('hide')

Template.checkoutDialog.events
  'click [data-action=openCheckoutDialog]': ->
    if Meteor.isCordova
      result = cordova.plugins.barcodeScanner.scan (res, err) ->
        if res
          item = Inventory.find {barcode: item.text}
          if item
            Session.set "checkoutItem", item
          else
            Session.set "checkoutError", "Item not found. Try searching by name or barcode number."
          $('#checkoutDialog').modal('show')
        else
          Session.set "checkoutError", "Error in scanning barcode. Try searching by name or barcode number."
          $('#checkoutDialog').modal('show')
    else
      $('#checkoutDialog').modal('show')

  'click button[data-action=submit]': (e, tmpl) ->
    item = Session.get "checkoutItem"
    if tmpl.$('button[data-action=submit]').html() is 'Check Out'
      now = new Date()
      #Validation - expected return date.
      expectedReturn = tmpl.$('input[name=returnDate]').val()
      if new Date(expectedReturn) < now
        tmpl.$('input[name=returnDate]').parent().parent().addClass('has-error')
        Session.set "checkoutExpectedReturnError", "Expected return date must be after today."
      #Validation - User assigned to. If the user is good, we call the check out method.
      assignedTo = tmpl.$('input[name=assignedTo]').val()
      if assignedTo is ""
        tmpl.$('input[name=assignedTo]').parent().parent().addClass('has-error')
        Session.set "checkoutAssignedToError", "You must assign the item to someone."
      else
        Meteor.call 'checkUsername', tmpl.$('input[name=assignedTo]').val(), (err, res) ->
          if res
            Meteor.call "checkOutItem", item._id, assignedTo, expectedReturn
            resetCheckoutDialog(tmpl)
          else
            Session.set "checkoutAssignedToError", "User not found."
            tmpl.$('button[data-action=checkUsername]').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
            tmpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-remove"></span>')
          
    else if tmpl.$('button[data-action=submit]').html() is 'Check In'
      Meteor.call "checkInItem", item._id
      resetCheckoutDialog(tmpl)

  'click button[data-action=cancel]': (e, tmpl) ->
    resetCheckoutDialog(tmpl)

  'keyup': (e, tmpl) ->
    if e.keyCode is 27
      resetCheckoutDialog(tmpl)

  'click button[data-action=checkUsername]': (e, tmpl) ->
    unless tmpl.$('input[name=assignedTo]').val() is undefined
      Meteor.call 'checkUsername', tmpl.$('input[name=assignedTo]').val(), (err, res) ->
        if res
          Session.set "checkoutAssignedToError", null
          tmpl.$('input[name=assignedTo]').parent().parent().removeClass('has-error').addClass('has-success')
          tmpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-ok"></span>')
          tmpl.$('button[data-action=checkUsername]').removeClass('btn-danger').removeClass('btn-primary').addClass('btn-success')
        else
          Session.set "checkoutAssignedToError", "User not found."
          tmpl.$('input[name=assignedTo]').parent().parent().removeClass('has-success').addClass('has-error')
          tmpl.$('button[data-action=checkUsername]').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
          tmpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-remove"></span>')

Template.checkoutDialog.rendered = ->
  this.$('input[name=returnDate]').datepicker()

Template.checkoutDialog.helpers
  checkoutAssignedToError: -> Session.get "checkoutAssignedToError"
  checkoutExpectedReturnError: -> Session.get "checkoutExpectedReturnError"
  rootUrl: ->
    if Meteor.isCordova
      __meteor_runtime_config__.ROOT_URL.replace(/\/$/, '') + __meteor_runtime_config__.ROOT_URL_PATH_PREFIX
    else
      __meteor_runtime_config__.ROOT_URL.replace /\/$/, ''
  thumbnailUrl: ->
    item = Session.get "checkoutItem"
    if item.imageId
      return FileRegistry.findOne({_id: item.imageId})?.thumbnail
    else
      return null
  item: -> Session.get "checkoutItem"
  hidden: ->
    if Session.get "checkoutItem"
      ""
    else
      "none"
  attr: ->
    item = Session.get "checkoutItem"
    if item?.assignedTo
      "color: red;"
    else
      "color: black;"
  disabled: ->
    item = Session.get "checkoutItem"
    if item?.assignedTo
      "disabled"
    else
      null

  settings: {
    position: 'top'
    limit: 3
    rules: [
      {
        collection: Inventory
        template: Template.searchFields
        matchAll: true
        field: 'name'
        selector: (match) ->
          regex = new RegExp match, 'i'
          return $or: [{'name': regex}, {'barcode': regex}]
        callback: (doc, element) ->
          Session.set "checkoutError", null
          Session.set "checkoutItem", doc
      }
    ]
  }

