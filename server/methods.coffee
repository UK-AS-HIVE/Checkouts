Meteor.methods
  checkOutItem: (id, username, expectedReturn) ->
    #TODO: Query LDAP to find user (maybe before this method is called). Set checkoutTime and expectedReturn if there is one. Figure out how job logging and scheduling is going to work.
    now = new Date()
    Inventory.update {_id: id}, {$set: {assignedTo: username, schedule: {timecheckedOut: now, expectedReturn: expectedReturn}}}

  addItem: (itemObj) ->
    now = new Date()
    item = Inventory.insert
      name: itemObj.name
      description: itemObj.description
      serialNo: itemObj.serialNo
      propertyTag: itemObj.propertyTag
      category: itemObj.category
      imageId: itemObj.imageId
      barcode: itemObj.barcode
      schedule:
        timeCheckedOut: null
        timeCheckedIn: null
        timeReserved: null
        expectedReturn: null

