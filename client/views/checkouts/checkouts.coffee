Template.checkouts.helpers
  checkoutItem: -> Inventory.find()

  isAdmin: -> return isAdmin(Meteor.user().id)

Template.checkouts.events
  'click #checkOutButton': ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        #Open some window/modal dialog allowing a user to be selected for assignment.
      else
        alert("Error in scanning barcode.") #Make this meaningful.

   'click #checkInButton': ->
     result = cordova.plugins.barcodeScanner.scan (res, err) ->
       if res
         #Open some window/modal dialog to give item info and info about who the item was assigned to.
       else
         alert("Error in scanning barcode.") #Make this meaningful.

