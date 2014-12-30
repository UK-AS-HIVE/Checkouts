Template.checkouts.helpers
  checkoutItem: -> Inventory.find()

  isAdmin: -> return isAdmin(Meteor.user().id)
