Template.checkoutDialog.events
    'click #submitButton': (e, tmpl) ->
      name = tmpl.find('input[name=searchFields]')
      item = Inventory.findOne {name: name}
      assignedTo = tmpl.find('input[name=codAssignedTo]')
      expectedReturn = tmpl.find('input[name=datepicker]')
      Meteor.call "checkOutItem", item._id, assignedTo, expectedReturn
    'click #cancelButton': (e, tmpl) ->

    'keyup': (e, tmpl) ->
      if e.keyCode is 27
        $('#checkoutDialog').modal('toggle')

Template.checkoutDialog.rendered = ->
  $('#datepicker').datepicker()

Template.checkoutDialog.helpers
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
          $('#codDescription').val(doc.description)
          if doc.assignedTo
            $('#codAssignedTo').val(doc.assignedTo)
            $('#codAssignedTo').attr("disabled", "disabled")
            $('#codDatepicker').val(doc.schedule.expectedReturn)
            $('#codDatepicker').attr("disabled","disabled")
          $('#checkoutDialog').find(":hidden").show()
      }
    ]
  }
