Meteor.methods
  checkOutItem: (name, username, expectedReturn) ->
    #TODO: Query LDAP to find user (maybe before this method is called). Insert into checkout log.
    now = new Date()
    Inventory.update {name: name}, {$set: {assignedTo: username, 'schedule.timeCheckedOut': now, 'schedule.expectedReturn': expectedReturn, 'schedule.timeCheckedIn': ''}}

  checkInItem: (name) ->
    now = new Date()
    Inventory.update {name: name}, {$set: {assignedTo: "", 'schedule.timeCheckedOut': '','schedule.expectedReturn': '', 'schedule.timeCheckedIn': 'now'}}

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
      assignedTo: null
      schedule:
        timeCheckedOut: null
        timeCheckedIn: null
        timeReserved: null
        expectedReturn: null

  addDeletedItem: (itemObj) ->
    DeletedInventory.insert itemObj
