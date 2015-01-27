Meteor.methods
  checkOutItem: (id, username, expectedReturn) ->
    #TODO: Query LDAP to find user (maybe before this method is called). Insert into checkout log.
    now = new Date()
    #In addition to checking out the item, we nullify any reservation. This might not be ideal.
    Inventory.update {_id: id}, {$set: {assignedTo: username, 'checkoutLog.timeCheckedOut': now, expectedReturn: expectedReturn, 'checkoutLog.timeCheckedIn': '', reservation: null}}

  checkInItem: (id) ->
    now = new Date()
    Inventory.update {_id: id}, {$set: {assignedTo: null, expectedReturn: null, 'checkoutLog.timeCheckedIn': now}}

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

  cancelReservation: (id) ->
    Inventory.update {_id: id}, {$set: {reservation: null}}

  checkUsername: (username) ->
    #Not completely sure if this is going to work. If we get an error, re-bind and try again.
    client = LDAP.createClient(Meteor.settings.ldap.serverUrl)
    LDAP.bind client, Meteor.settings.ldapDummy.username, Meteor.settings.ldapDummy.password
    result = LDAP.search client, username
    client.unbind()
    return result
    
