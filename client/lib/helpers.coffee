Template.registerHelper 'isAdmin', () ->
  #Possible to update this later, but for now we're doing Admin privileges by SG membership. It's likely that eventually there'll be a smaller list for Inventory Managers.
  user = Meteor.users.findOne {}, {_id: Meteor.userId(), memberOf: /.*SGASHIVE.*/ }
  if user
    return true
  else
    return false

Template.registerHelper 'isCordova', () ->
  return Meteor.isCordova

Meteor.startup () ->
  Session.set "availableFilter", "Any"
  Session.set "filters", []

String.prototype.capitalize = ->
  #A method to automatically capitalize the first letter of a string.
  this.charAt(0).toUpperCase() + this.substr(1)
