@isAdmin = ->
  #No arguments needed. Will use the currently logged in userId
  if Meteor.users.findOne {_id: Meteor.userId(), memberOf: /.*SGASSupportStaff.*/ }
    return true
  return false

@Inventory = new Meteor.Collection 'inventory'
@Inventory.allow
  insert: (userId, doc) ->
    return isAdmin(userId) #TODO: Probably make a method for inserting to check for duplicates
@Inventory.attachSchema new SimpleSchema
  name:
    type: String
    label: "Name"
  description:
    type: String
    label: "Description"
  image:
    type: String
  propertyTag:
    type: String
    label: "Property Tag"
    optional: true
  serialNo:
    type: String
    label: "Service Tag or Serial Number"
    optional: true
  category:
    type: String
    label: "Category"
  barcode:
    type: String
    label: "Barcode"
    optional: true
  assignedTo:
    type: String
    label: "Assigned to User"
    optional: true
  quantity:
    type: Number
    label: "Quantity"
    optional: true
  quantityUnit:
    type: String
    label: "Units"
    optional: true

@Schedule = new Meteor.Collection 'schedule'
@Schedule.attachSchema new SimpleSchema
  inventoryId:
    type: String
    label: "Id"
  timeCheckedOut:
    type: new Date()
    label: "Time Checked Out"
  timeCheckedIn:
    type: new Date()
    label: "Time Checked In"
  timeReserved:
    type: new Date()
    label: "Time Reserved"
  timeReservedUntil:
    type: new Date()
    label: "Time Reserved Until"
