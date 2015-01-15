Template.checkoutDialog.events
  'click [data-action=openCheckoutDialog]': ->
    if Meteor.isCordova
      result = cordova.plugins.barcodeScanner.scan (res, err) ->
        if res
          item = Inventory.find {barcode: item.text}
          Session.set "codItem", item
          $('#checkoutDialog').modal('toggle')
        else
          alert("Error in scanning barcode. Try searching by name or number.")
          $('#checkoutDialog').modal('toggle')
    else
      $('#checkoutDialog').modal('toggle')

  'click #submitButton': (e, tmpl) ->
    #Putting this all into one button might make things a bit tough on readability.
    name = tmpl.find('input[name=searchFields]').value
    if $('#submitButton').html() is 'Check Out'
      now = new Date()
      assignedTo = $('#codAssignedTo').val()
      if assignedTo is ""
        alert "You must assign the item to someone."
      else
        #TODO: Verify assingedTo is acceptable.
        expectedReturn = $('#codDatepicker').val()
        #The datepicker control keeps expectedReturn acceptable. Thanks, datepicker!
        if new Date(expectedReturn) < now
          alert("Expected return date must be after today.")
        else
          #We're trusting the name, as the submit button only becomes available when selecting from autocomplete.
          Meteor.call "checkOutItem", name, assignedTo, expectedReturn
          $('#checkoutDialog').modal('toggle')
          Session.set "codItem", null
    else if $('#submitButton').html() is 'Check In'
      Meteor.call "checkInItem", name
      $('#checkoutDialog').modal('toggle')
      Session.set "codItem", null

  'click #cancelButton': (e, tmpl) ->
    Session.set "codItem", null

  'keyup': (e, tmpl) ->
    if e.keyCode is 27
      $('#cancelButton').click()

Template.checkoutDialog.rendered = ->
  $('#codDatepicker').datepicker()

Template.checkoutDialog.helpers
  item: -> Session.get "codItem"
  hidden: ->
    if Session.get "codItem"
      ""
    else
      "none"
  attr: ->
    item = Session.get "codItem"
    if item?.assignedTo
      "color: red;"
    else
      "color: black;"
  disabled: ->
    item = Session.get "codItem"
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
          Session.set "codItem", doc
      }
    ]
  }

