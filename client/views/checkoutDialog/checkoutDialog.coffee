resetCheckoutDialog = (tmpl) ->
  tmpl.$('.has-error').removeClass('has-error')
  tmpl.$('.has-success').removeClass('has-success')
  Session.set "checkoutError", null
  Session.set "checkoutItem", null
  Session.set "checkoutAssignedToError", null
  Session.set "checkoutExpectedReturnError", null
  $('#checkoutCheckBtn').addClass('btn-primary').removeClass('btn-success').removeClass('btn-danger')
  $('#checkoutCheckBtn').html('Check Username')
  $('#checkoutAssignedTo').val('')
  $('#checkoutDatepicker').val('')
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

  'click #checkoutSubmitBtn': (e, tmpl) ->
    item = Session.get "checkoutItem"
    if $('#checkoutSubmitBtn').html() is 'Check Out'
      now = new Date()
      #Validation - expected return date.
      expectedReturn = $('#checkoutDatepicker').val()
      if new Date(expectedReturn) < now
        $('#checkoutExpectedReturn').parent().parent().addClass('has-error')
        Session.set "checkoutExpectedReturnError", "Expected return date must be after today."
      #Validation - User assigned to. If the user is good, we call the check out method.
      assignedTo = $('#checkoutAssignedTo').val()
      if assignedTo is ""
        $('#checkoutAssignedTo').parent().parent().addClass('has-error')
        Session.set "checkoutAssignedToError", "You must assign the item to someone."
      else
        Meteor.call 'checkUsername', $('#checkoutAssignedTo').val(), (err, res) ->
          if res
            Meteor.call "checkOutItem", item._id, assignedTo, expectedReturn
            resetCheckoutDialog(tmpl)
          else
            Session.set "checkoutAssignedToError", "User not found."
            $('#checkoutCheckBtn').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
            $('#checkoutCheckBtn').html('<span class="glyphicon glyphicon-remove"></span>')
          
    else if $('#checkoutSubmitBtn').html() is 'Check In'
      Meteor.call "checkInItem", item._id
      resetCheckoutDialog(tmpl)

  'click #checkoutCancelBtn': (e, tmpl) ->
    resetCheckoutDialog(tmpl)

  'keyup': (e, tmpl) ->
    if e.keyCode is 27
      resetCheckoutDialog(tmpl)

  'click #checkoutCheckBtn': (e, tmpl) ->
    unless $('#checkoutAssignedTo').val() is undefined
      Meteor.call 'checkUsername', $('#checkoutAssignedTo').val(), (err, res) ->
        if res
          Session.set "checkoutAssignedToError", null
          $('#checkoutAssignedTo').parent().parent().removeClass('has-error').addClass('has-success')
          $('#checkoutCheckBtn').html('<span class="glyphicon glyphicon-ok"></span>')
          $('#checkoutCheckBtn').removeClass('btn-danger').removeClass('btn-primary').addClass('btn-success')
        else
          Session.set "checkoutAssignedToError", "User not found."
          $('#checkoutAssignedTo').parent().parent().removeClass('has-success').addClass('has-error')
          $('#checkoutCheckBtn').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
          $('#checkoutCheckBtn').html('<span class="glyphicon glyphicon-remove"></span>')

Template.checkoutDialog.rendered = ->
  $('#checkoutDatepicker').datepicker()

Template.checkoutDialog.helpers
  checkoutAssignedToError: -> Session.get "checkoutAssignedToError"
  checkoutExpectedReturnError: -> Session.get "checkoutExpectedReturnError"
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

