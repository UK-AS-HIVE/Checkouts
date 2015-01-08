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
  Session.set "availableFilter", "All"
  Session.set "categoryFilter", []
  Session.set "textFilter", {type: "", text: ""}
