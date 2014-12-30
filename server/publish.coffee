Meteor.publish 'fileRegistry', ->
  FileRegistry.find()

Meteor.publish 'inventory', ->
  #For now we publish the whole inventory to everyone.
  #We may not publish the assignedTo field in the future to non-admin users.
  return Inventory.find()

Meteor.publish 'userData', ->
  return Meteor.users.find {},{fields: {memberOf: 1}}