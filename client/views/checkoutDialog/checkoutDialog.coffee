Template.checkoutDialog.events
  'click #checkBarcode': (e, tmpl) ->
    item = Inventory.findOne {barcode: tmpl.find('input[name=barcode]').value}
    if (item)
      $('#name').val(item.name)
      $('#description').val(item.description)
      $('#assignedTo').val(item.assignedTo)

   'click #checkName': (e, tmpl) ->
     console.log tmpl.find('input[name=name]').value
     if Inventory.find({barcode: $('#name').value}).count() is 1
       item = Inventory.findOne {name: tmpl.find('input[name=name]').value}
       $('#barcode').val(item.barcode)
       $('#description').val(item.description)
       $('#assignedTo').val(item.assignedTo)

   'click #submitItem': (e, tmpl) ->
     name = tmpl.find('input[name=name]').value
     barcode = tmpl.find('input[name=barcode]').value
     assignedTo = tmpl.find('input[name=assignedTo]').value

     if not name and not barcode
       alert("You must enter an item to be checked out.")
     if not assignedTo
       alert("You must assign the item to a user!")
     else
       #Check to make sure our barcode/name pair is valid. There might be a better way to do this.
       item = Inventory.findOne {name: name}
       item2 = Inventory.findOne {barcode: barcode}
       if barcode = item.barcode and name = item2.name
         Meteor.call("checkOutItem",item._id,assignedTo)
         $('#checkoutDialog').modal('toggle') #TODO: Clear form data
       else
         alert("Mismatch in item name and barcode. Please choose a valid item.")

