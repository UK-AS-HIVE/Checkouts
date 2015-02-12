Template.itemDialog.helpers
  item: -> Session.get "editCheckoutItem"
  imageName: ->
    if Session.get 'currentUploadId'
      return FileRegistry.findOne(Session.get('currentUploadId'))?.filename
    else if Session.get 'editCheckoutItem'
      return FileRegistry.findOne(Session.get('editCheckoutItem').imageId)?.filename
    else return null

Template.itemDialog.rendered = ->
  this.$('input[name=category]').autocomplete { lookup: _.uniq(_(Inventory.find().fetch()).pluck "category") }

Template.itemDialog.events
  'click button[data-action=submit]': (e, tmpl) ->
    addItem e, tmpl

  'hidden.bs.modal #itemDialog': (e, tmpl) ->
    Session.set "currentUploadId", null
    Session.set "editCheckoutItem", null
    tmpl.$(':input').val('')
    tmpl.$('.has-error').removeClass('has-error')
    tmpl.$('span[class=error]').hide()

  'keyup': (e, tmpl) ->
    if e.keyCode is 13
      tmpl.$('button[data-action=submit]').click()
    if e.keyCode is 27
      tmpl.$('button[data-action=cancel]').click()

  'click button[data-action=scanBarcode]': (e, tmpl) ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        console.log res
        tmpl.$('input[name=barcode]').val(res.text)
      else
        tmpl.$('span[name=barcode]').text("Error in scanning barcode. Please enter manually.")
        tmpl.$('span[name=barcode]').show()

   'click button[data-action=takePicture]': ->
     getMediaFunctions().capturePhoto (fileId) ->
       console.log 'Uploaded a file, got _id: ', fileId
       Session.set 'currentUploadId', fileId

   'click button[data-action=uploadPicture]': ->
     getMediaFunctions().pickLocalFile (fileId) ->
       console.log 'Uploaded a file, got _id: ', fileId
       Session.set 'currentUploadId', fileId

addItem = (e, tmpl) ->
  if tmpl.$('button[data-action=submit]').html() is "Add Item"
    item = Inventory.insert  {
      name: tmpl.find('input[name=name]').value
      description: tmpl.find('input[name=description]').value
      serialNo: tmpl.find('input[name=serialNo]').value
      propertyTag: tmpl.find('input[name=propertyTag]').value
      category: tmpl.find('input[name=category]').value
      imageId: Session.get "currentUploadId"
      barcode: tmpl.find('input[name=barcode]').value
    },
    (err, result) ->
      if err
        handleError(tmpl, err.invalidKeys)
      else
        $('#itemDialog').modal('hide')
  else
    if Session.get "currentUploadId"
      imageId = Session.get "currentUploadId"
    else if Session.get("editCheckoutItem")?.imageId?
      imageId = Session.get("editCheckoutItem").imageId
    else imageId = null
    Inventory.update {_id: Session.get("editCheckoutItem")._id}, {$set: {
      name: tmpl.find('input[name=name]').value
      description: tmpl.find('input[name=description]').value
      serialNo: tmpl.find('input[name=serialNo]').value
      propertyTag: tmpl.find('input[name=propertyTag]').value
      category: tmpl.find('input[name=category]').value
      imageId: imageId
      barcode: tmpl.find('input[name=barcode]').value
    }},
    (err, result) ->
      if err
        handleError(tmpl, err.invalidKeys)
      else
        $('#itemDialog').modal('hide')

handleError = (tmpl, keys) ->
  #Clear all of our error fields before re-validating.
  tmpl.$('.has-error').removeClass('has-error')
  tmpl.$('span[class=error]').hide()
  for key in keys
    tmpl.$('input[name='+key.name+']').parent().parent().addClass('has-error')
    if key.type is "notUnique"
      tmpl.$('span[name='+key.name+']').text(key.name.capitalize() + " must be unique.")
      tmpl.$('span[name='+key.name+']').show()
    if key.type is "required"
      tmpl.$('span[name='+key.name+']').text("A "+key.name+" is required.")
      tmpl.$('span[name='+key.name+']').show()


getMediaFunctions = ->
  requiredFunctions = ['pickLocalFile', 'capturePhoto', 'captureAudio', 'captureVideo']
  if Meteor.isCordova
    CordovaMedia
  else
    WebMedia
