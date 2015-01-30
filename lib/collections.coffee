@isAdmin = ->
  #No arguments needed. Will use the currently logged in userId
  if Meteor.users.findOne {_id: Meteor.userId(), memberOf: /.*SGASSupportStaff.*/ }
    return true
  return false

@DeletedInventory = new Mongo.Collection 'deletedInventory'
@DeletedInventory.allow
  insert: (userId, doc) ->
    return isAdmin(userId)

@Inventory = new Mongo.Collection 'inventory'
@Inventory.allow
  insert: (userId, doc) ->
    return isAdmin(userId)
  update: (userId, doc) ->
    return isAdmin(userId)

@Inventory.attachSchema new SimpleSchema
  name:
    type: String
    label: "Name"
    unique: true
  description:
    type: String
    label: "Description"
    optional: true
  imageId:
    type: String
  propertyTag:
    type: String
    label: "Property Tag"
    optional: true
    unique: true
  serialNo:
    type: String
    label: "Service Tag or Serial Number"
    optional: true
    unique: true
  category:
    type: String
    label: "Category"
  barcode:
    type: String
    label: "Barcode"
    unique: false
    optional: true
  quantity:
    type: Number
    label: "Quantity"
    optional: true
  quantityUnit:
    type: String
    label: "Units"
    optional: true
  assignedTo:
    #Current item info is stored under the item. On check-in, these are moved into checkoutLog.
    type: String
    optional: true
  timeCheckedOut:
    type: new Date()
    optional: true
  expectedReturn:
    type: new Date()
    optional: true
  reservation:
    type: Object
    optional: true
  checkoutLog:
    #Stores time checked in, checked out, and user checked out to. 
    type: [Object]
    optional: true
    defaultValue: []
  'checkoutLog.$.timeCheckedOut':
    type: new Date()
    label: "Time Checked Out"
  'checkoutLog.$.timeCheckedIn':
    type: new Date()
    label: "Time Checked In"
  'checkoutLog.$.assignedTo':
    type: String
    label: "Log Assigned To"
  'reservation.dateReserved':
    type: new Date()
    label: "Date Reserved"
    optional: true
  'reservation.expectedReturn':
    type: new Date()
    label: "Expected Return"
    optional: true
  'reservation.assignedTo':
    type: String
    label: "Reservation Assigned To"
    optional: true
