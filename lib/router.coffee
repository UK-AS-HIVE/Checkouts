Router.configure
  layoutTemplate: 'layoutTemplate'
  wait: -> [Meteor.subscribe 'fileRegistry']

Router.map ->
  @route 'checkouts',
    path: '/'
    waitOn: -> [Meteor.subscribe 'userData']

  @route 'serveFile',
    path: '/file/:filename'
    where: 'server'
    action: ->
      fs = Npm.require 'fs'
      # TODO verify file exists
      # TODO permissions check
      expire = new Date()
      expire.setFullYear(expire.getFullYear()+1)
      fd = fs.openSync FileRegistry.getFileRoot() + @params.filename, 'r'
      try
        stat = fs.fstatSync fd
        if @request.headers.range?
          start = parseInt(@request.headers.range.substr('bytes='.length))
          end = parseInt(@request.headers.range.split('-').pop())
          bufferSize = if isNaN(end) then Math.min(1024*1024,stat.size) else (1+end-start)
          console.log 'bufferSize: ', bufferSize
          buffer = new Buffer(bufferSize)
          bytesRead = fs.readSync fd, buffer, 0, bufferSize, Math.min(start, stat.size)
          @response.writeHead 206,
            'Content-Range': 'bytes '+start+'-'+(start+bytesRead-1) + '/' + stat.size
            'Content-Length': bytesRead
            'Content-Type': 'video/mp4'
            'Accept-Ranges': 'bytes'
            'Cache-Control': 'no-cache'
          @response.end buffer.slice(0,bytesRead)
        else
          @response.writeHead 200,
            'Content-Disposition': 'attachment; filename='+@params.filename.substr(@params.filename.indexOf('-')+1)
            'Content-type': 'image/jpg'
            'Expires': moment(expire).format('ddd, DD MMM YYYY HH:mm:ss GMT')
          @response.end fs.readFileSync (FileRegistry.getFileRoot() + @params.filename)
      catch e
        console.log 'exception from request: ', @params.filename, @request.headers.range
        console.log e
      finally
        fs.closeSync fd
