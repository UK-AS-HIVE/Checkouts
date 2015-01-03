Template.registerHelper 'isAdmin', () ->
  user = Meteor.users.findOne {}, {_id: Meteor.userId(), memberOf: /.*SGASSupportStaff.*/ }
  if user
    return true
  else
    return false

Template.registerHelper 'isCordova', () ->
  return Meteor.isCordova
