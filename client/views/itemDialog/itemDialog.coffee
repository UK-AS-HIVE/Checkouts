Template.itemDialog.helpers
  categoryHelper: {
    position: 'bottom'
    limit: 3
    rules: [
      {
        collection: Inventory
        field: "category"
        template: Template.categoryTokenSearch
        noMatchTemplate: Template.noMatchTemplate
      }
    ]
  }
  item: -> Session.get "editCheckoutItem"

Template.noMatchTemplate.helpers
  input: -> $('#newCheckoutCategory').val()

Template.itemDialog.events
  'click #itemSubmitButton': (e, tmpl) ->
    addItem(e, tmpl)
    tmpl.$(':input').val('')
  'click #itemCancelButton': (e, tmpl) ->
    Session.set "editCheckoutItem", null
    tmpl.$(':input').val('')
  'keyup .itemInput': (e, tmpl) ->
    if e.keyCode is 13
      $('#itemSubmitButton').click()
    if e.keyCode is 27
      $('#itemCancelButton').click()
  'click #scanBarcode': (e, tmpl) ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        console.log res
        $('input[name=barcode]').val(res.text)
      else
        alert("Error in scanning barcode.")
   'click #takePicture': ->
     #TODO: Show a thumbnail, associate image with inventory item, remove upload if cancelled. 
     getMediaFunctions.capturePhoto()
   'click #uploadPicture': ->
     #TODO: See above.
     getMediaFunctions().pickLocalFile()

addItem = (e, tmpl) ->
  #TODO: Check and see if everything is cool. "Name", "description", "category" are definitely required; probably image too. Clear form after submission.
  name = tmpl.find('input[name=name]').value
  description = tmpl.find('input[name=description]').value
  serialNo = tmpl.find('input[name=serialNo]').value
  propertyTag = tmpl.find('input[name=propertyTag]').value
  category = tmpl.find('#newCheckoutCategory').value
  imageId = "test"
  barcode = tmpl.find('input[name=barcode]').value
  $('#newCheckout').modal('toggle')
  if $('#itemSubmitButton').html() is "Add Item"
    item = Inventory.insert  {
      name: name
      description: description
      serialNo: serialNo
      propertyTag: propertyTag
      category: category
      imageId: imageId
      barcode: barcode
    }
  else
    item = Session.get "editCheckoutItem"
    Inventory.update {_id: item._id}, {$set: {
      name: name
      description: description
      serialNo: serialNo
      propertyTag: propertyTag
      category: category
      imageId: imageId
      barcode: barcode
    }}
  Session.set "editCheckoutItem", null

getMediaFunctions = ->
  requiredFunctions = ['pickLocalFile', 'capturePhoto', 'captureAudio', 'captureVideo']
  if Meteor.isCordova
    CordovaMedia
  else
    WebMedia

