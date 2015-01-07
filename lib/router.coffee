Router.configure
  layoutTemplate: 'layoutTemplate'
  wait: -> [Meteor.subscribe 'fileRegistry']

Router.map ->
  @route 'checkouts',
    path: '/'
    waitOn: -> [Meteor.subscribe 'userData']
