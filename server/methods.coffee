Meteor.methods
  checkOutItem: (name, username, expectedReturn) ->
    #TODO: Query LDAP to find user (maybe before this method is called). Insert into checkout log.
    now = new Date()
    Inventory.update {name: name}, {$set: {assignedTo: username, 'checkoutLog.timeCheckedOut': now, expectedReturn: expectedReturn, 'checkoutLog.timeCheckedIn': ''}}

  checkInItem: (name) ->
    now = new Date()
    Inventory.update {name: name}, {$set: {assignedTo: "", 'checkoutLog.timeCheckedIn': now}}

  addItem: (itemObj) ->
    #This is done very explicitly due to errors in just inserting/updating objects.
    item = Inventory.insert
      name: itemObj.name
      description: itemObj.description
      serialNo: itemObj.serialNo
      propertyTag: itemObj.propertyTag
      category: itemObj.category
      imageId: itemObj.imageId
      barcode: itemObj.barcode

  addDeletedItem: (itemObj) ->
    DeletedInventory.insert itemObj

  reserveItem: (id, reservation) ->
    Inventory.update {_id: id}, {$set: {reservation: {dateReserved: reservation.dateReserved, expectedReturn: reservation.expectedReturn, assignedTo: reservation.assignedTo}}}
