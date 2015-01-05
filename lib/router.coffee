Router.configure
  layoutTemplate: 'layoutTemplate'
  #wait: -> [Meteor.subscribe 'fileRegistry']

Router.route '/',
  action: ->
    if !this.userId
      this.render('login')
    else
      this.render('checkouts')
  #waitOn: -> [Meteor.subscribe 'userData']

Router.map ->
  @route 'serveFile',
    path: '/file/:filename'
    where: 'server'
    action: ->
      fs = Npm.require 'fs'
      # TODO verify file exists
      # TODO permissions check
      @response.writeHead 200,
        'Content-type': 'image/jpg'
        'Content-Disposition': 'attachment; filename='+@params.filename
      console.log 'serving ', @params.filename
      @response.end fs.readFileSync (FileRegistry.getFileRoot() + @params.filename)

  @route 'serveThumbnail',
    path: '/thumbnail/:filename'
    where: 'server'
    action: (filename) ->
      fs = Npm.require 'fs'
      # TODO verify thumbnail exists
      # TODO permissions check
      @response.writeHead 200,
        'Content-type': 'image/jpg'
      @response.end fs.readFileSync (FileRegistry.getFileRoot() + @params.filename.substr(0, @params.filename.lastIndexOf('.')) + '_thumbnail.jpg')


