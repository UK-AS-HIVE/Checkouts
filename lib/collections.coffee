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
    unique: true
  description:
    type: String
    label: "Description"
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
    unique: true
  quantity:
    type: Number
    label: "Quantity"
    optional: true
  quantityUnit:
    type: String
    label: "Units"
    optional: true
  assignedTo:
    type: String
    defaultValue: ""
    optional: true
  schedule:
    type: Object
    optional: true
  'schedule.timeCheckedOut':
    type: new Date()
    label: "Time Checked Out"
    optional: true
  'schedule.timeCheckedIn':
    type: new Date()
    label: "Time Checked In"
    optional: true
  'schedule.timeReserved':
    type: new Date()
    label: "Time Reserved"
    optional: true
  'schedule.expectedReturn':
    type: new Date()
    label: "Expected Return"
    optional: true
