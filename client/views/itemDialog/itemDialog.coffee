Template.itemDialog.helpers
  categoryHelper: {
    position: 'bottom'
    limit: 3
    rules: [
      {
        collection: Inventory
        field: "category"
        template: Template.categorySearch
        noMatchTemplate: Template.noMatchTemplate
      }
    ]
  }
  item: -> Session.get "editCheckoutItem"
  imageName: ->
    if Session.get 'currentUploadId'
      return FileRegistry.findOne(Session.get('currentUploadId'))?.filename
    else if Session.get 'editCheckoutItem'
      return FileRegistry.findOne(Session.get('editCheckoutItem').imageId)?.filename
    else return null

Template.noMatchTemplate.helpers
  input: -> $('#itemCategory').val()
  
Template.itemDialog.rendered = ->
  this.$('input[name=category]').autocomplete { lookup: _.uniq(_(Inventory.find().fetch()).pluck "category") }

Template.itemDialog.events
  'click button[data-action=submit]': (e, tmpl) ->
    addItem e, tmpl
  'click button[data-action=cancel]': (e, tmpl) ->
    Session.set "currentUploadId", null
    Session.set "editCheckoutItem", null
    tmpl.$(':input').val('')
    tmpl.$('.has-error').removeClass('has-error')
    tmpl.$('span[class=error]').hide()

  'keyup .itemInput': (e, tmpl) ->
    if e.keyCode is 13
      tmpl.$('button[data-action=submit]').click()
    if e.keyCode is 27
      tmpl.$('button[data-action=cancel]').click()

  'click #scanBarcode': (e, tmpl) ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        console.log res
        tmpl.$('input[name=barcode]').val(res.text)
      else
        alert("Error in scanning barcode.")

   'click #takePicture': ->
     #TODO: Show a thumbnail, associate image with inventory item, remove upload if cancelled. 
     getMediaFunctions.capturePhoto()
   'click #uploadPicture': ->
     #TODO: See above.
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
        Session.set "editCheckoutItem", null
        tmpl.$(':input').val('')
        $('#itemDialog').modal('toggle')
  else
    if Session.get "currentUploadId"
      imageId = Session.get "currentUploadId"
    else
      imageId = Session.get("editCheckoutItem")?.imageId?
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
        Session.set "currentUploadId", null
        Session.set "editCheckoutItem", null
        tmpl.$(':input').val('')
        tmpl.$('span[class=error]').hide()
        $('#itemDialog').modal('toggle')



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

