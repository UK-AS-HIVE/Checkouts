Meteor.methods
  checkOutItem: (id, username, expectedReturn) ->
    #TODO: Query LDAP to find user (maybe before this method is called). Set checkoutTime and expectedReturn if there is one. Figure out how job logging and scheduling is going to work.
    Inventory.update {_id: id}, {$set: {assignedTo: username}}
