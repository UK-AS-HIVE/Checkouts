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
  imageName: -> FileRegistry.findOne(Session.get('currentUploadId'))?.filename

Template.noMatchTemplate.helpers
  input: -> $('#itemCategory').val()

Template.itemDialog.events
  'click #itemSubmitButton': (e, tmpl) ->
    addItem e, tmpl
  'click #itemCancelButton': (e, tmpl) ->
    Session.set "editCheckoutItem", null
    tmpl.$(':input').val('')
    tmpl.$('.has-error').removeClass('has-error')
    tmpl.$('span[class=error]').hide()

  'keyup .itemInput': (e, tmpl) ->
    if e.keyCode is 13
      $('#itemSubmitButton').click()
    if e.keyCode is 27
      $('#itemCancelButton').click()

  'click #scanBarcode': (e, tmpl) ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        console.log res
        $('#itemBarcode').val(res.text)
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
  if $('#itemSubmitButton').html() is "Add Item"
    item = Inventory.insert  {
      name: $('#itemName').val()
      description: $('#itemDescription').val()
      serialNo: $('#itemSerialNo').val()
      propertyTag: $('#itemPropertyTag').val()
      category: $('#itemCategory').val()
      imageId: 'test'
      barcode: $('#itemBarcode').val()
    },
    (err, result) ->
      if err
        handleError(tmpl, err.invalidKeys)
      else
        Session.set "editCheckoutItem", null
        tmpl.$(':input').val('')
        $('#itemDialog').modal('toggle')
  else
    item = Session.get "editCheckoutItem"
    Inventory.update {_id: item._id}, {$set: {
      name: $('#itemName').val()
      description: $('#itemDescription').val()
      serialNo: $('#itemSerialNo').val()
      propertyTag: $('#itemPropertyTag').val()
      category: $('#itemCategory').val()
      imageId: 'test'
      barcode: $('#itemBarcode').val()
    }},
    (err, result) ->
      if err
        handleError(tmpl, err.invalidKeys)
      else
        Session.set "editCheckoutItem", null
        tmpl.$(':input').val('')
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

