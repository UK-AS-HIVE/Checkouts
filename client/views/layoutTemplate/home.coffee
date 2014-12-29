endsWithAnyOf = (filename, extensions) ->
  check filename, String
  check extensions, Array

  f = filename.toLowerCase()

  for e in extensions
    if f.lastIndexOf(e.toLowerCase()) is f.length-e.length then return true
  return false

Template.checkouts.helpers
  connectionStatus: ->
    Meteor.status().status
  rootUrl: ->
    if Meteor.isCordova
      __meteor_runtime_config__.ROOT_URL.replace(/\/$/, '') + __meteor_runtime_config__.ROOT_URL_PATH_PREFIX
    else
      __meteor_runtime_config__.ROOT_URL.replace /\/$/, ''
  mediaFiles: ->
    FileRegistry.find({}, {sort: {timestamp: -1}})
  friendlySize: (bytes) ->
    if bytes > 1024*1024
      return (bytes/(1024*1024)).toFixed(2) + 'MB'
    else if bytes > 1024
      return (bytes/1024).toFixed(2) + 'KB'
    else
      return bytes
  isVideo: ->
    endsWithAnyOf @filename, ['.mov', '.mp4']
  isImage: ->
    endsWithAnyOf @filename, ['.jpg', '.png']

Template.checkouts.events
  'click input[value="Upload"]': ->
    getMediaFunctions().pickLocalFile()
  'click input[value="Photo"]': ->
    getMediaFunctions().capturePhoto()
  'click input[value="Audio"]': ->
    getMediaFunctions().captureAudio()
  'click input[value="Video"]': ->
    getMediaFunctions().captureVideo()

# TODO: figure out when and where to run
getMediaFunctions = ->
  requiredFunctions = ['pickLocalFile', 'capturePhoto', 'captureAudio', 'captureVideo']

  RunningInCordova = ->
    window._cordovaNative? || /iPhone|iPad|iPod|Android/i.test(navigator.userAgent)

  if RunningInCordova()
    CordovaMedia
  else
    WebMedia
