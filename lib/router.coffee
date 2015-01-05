Router.configure
  layoutTemplate: 'layoutTemplate'
  wait: -> [Meteor.subscribe 'fileRegistry']

Router.route '/',
  action: ->
    if !this.userId
      this.render('login')
    else
      this.render('checkouts')
  waitOn: -> [Meteor.subscribe 'userData']
