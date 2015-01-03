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
  'click .expand': (e,tmpl) ->
    console.log 'doin stuff'
    console.log $(e.target)
    $(e.target).next().slideToggle 100
    $expand = $(e.target).find(">:first-child")
    if $expand.text() is "+"
      $expand.text "-"
    else
      $expand.text "+"
   
