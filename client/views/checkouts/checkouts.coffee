Template.checkouts.helpers
  checkoutItem: -> Inventory.find()

  isAdmin: -> return isAdmin(Meteor.user().id)

Template.checkouts.events
  'click #checkOutButton': ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        openCheckoutDialog(res.text)
      else
        alert("Error in scanning barcode.") #Make this meaningful.

