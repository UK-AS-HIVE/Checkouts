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
          $('#checkoutDialog').modal('toggle')
        else
          Session.set "checkoutError", "Error in scanning barcode. Try searching by name or barcode number."
          $('#checkoutDialog').modal('toggle')
    else
      $('#checkoutDialog').modal('toggle')

  'click #submitButton': (e, tmpl) ->
    #Putting this all into one button might make things a bit tough on readability.
    name = tmpl.find('input[name=checkoutSearch]').value
    if $('#submitButton').html() is 'Check Out'
      now = new Date()
      assignedTo = $('#checkoutAssignedTo').val()
      if assignedTo is ""
        alert "You must assign the item to someone."
      else
        #TODO: Verify assingedTo is acceptable.
        expectedReturn = $('#checkoutDatepicker').val()
        #The datepicker control keeps expectedReturn acceptable. Thanks, datepicker!
        if new Date(expectedReturn) < now
          alert("Expected return date must be after today.")
        else
          #We're trusting the name, as the submit button only becomes available when selecting from autocomplete.
          Meteor.call "checkOutItem", name, assignedTo, expectedReturn
          $('#checkoutDialog').modal('toggle')
          Session.set "checkoutItem", null
          Session.set "checkoutError", null
          $('#checkoutDatepicker').val('')
    else if $('#submitButton').html() is 'Check In'
      Meteor.call "checkInItem", name
      Session.set "checkoutItem", null
      Session.set "checkoutError", null
      $('#checkoutDatepicker').val('')
      $('#checkoutDialog').modal('toggle')

  'click #cancelButton': (e, tmpl) ->
    Session.set "checkoutError", null
    Session.set "checkoutItem", null
    $('#checkoutDatepicker').val('')

  'keyup': (e, tmpl) ->
    if e.keyCode is 27
      $('#cancelButton').click()

Template.checkoutDialog.rendered = ->
  $('#checkoutDatepicker').datepicker()

Template.checkoutDialog.helpers
  error: -> Session.get "checkoutError"
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

