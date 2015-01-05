Template.checkoutDialog.events
   'click #submitButton': (e, tmpl) ->
     name = tmpl.find('input[name=name]').value
     barcode = tmpl.find('input[name=barcode]').value
     assignedTo = tmpl.find('input[name=assignedTo]').value
     expectedReturn = new Date(tmpl.find('input[name=datepicker]').value) || ""

     if not name and not barcode
       alert("You must enter an item to be checked out.")
     else if not assignedTo
       alert("You must assign the item to a user!")
     else
       #Check to make sure our barcode/name pair is valid. There might be a better way to do this.
       item = Inventory.findOne {name: name}
       item2 = Inventory.findOne {barcode: barcode}
       if barcode = item.barcode and name = item2.name
         Meteor.call("checkOutItem",item._id,assignedTo, expectedReturn)
         $('#checkoutDialog').modal('toggle')
         tmpl.$(':input').val('')
       else
         alert("Mismatch in item name and barcode. Please choose a valid item.")

    'click #cancelButton': (e, tmpl) ->
      tmpl.$(':input').val('')

Template.checkoutDialog.rendered = ->
  $('#datepicker').datepicker()
  Meteor.typeahead.inject()

Template.checkoutDialog.helpers
  searchFields: ->
    return [
      {
        name: 'Barcode'
        valueKey: 'barcode'
        local: () -> return Inventory.find().fetch()
        header: '<h2 class="header">Barcode</h2>'
        template: 'checkoutBarcode'
      }
      {
        name: 'Name'
        valueKey: 'name'
        local: () -> return Inventory.find().fetch()
        header: '<h2 class="header">Name</h2>'
        template: 'checkoutName'
      }
    ]
