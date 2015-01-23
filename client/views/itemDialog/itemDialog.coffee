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

Template.noMatchTemplate.helpers
  input: -> $('#itemCategory').val()

Template.itemDialog.events
  'click #itemSubmitButton': (e, tmpl) ->
    validateItemForm(e, tmpl
    )
  'click #itemCancelButton': (e, tmpl) ->
    Session.set "editCheckoutItem", null
    tmpl.$(':input').val('')
    tmpl.$('.has-error').removeClass('has-error')

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
     getMediaFunctions().pickLocalFile()

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
    }
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
    }}

  Session.set "editCheckoutItem", null
  tmpl.$(':input').val('')
  $('#itemDialog').modal('toggle')

validateItemForm = (e, tmpl) ->
  #TODO: Check uniqueness of name, barcode
  requiredFields = ['#itemName', '#itemCategory']
  for field in requiredFields
    if $(field).val()
      $(field).parent().parent().removeClass('has-error')
    else
      console.log $(field).val()
      $(field).parent().parent().addClass('has-error')
  if tmpl.findAll('.has-error').length is 0
    addItem(e, tmpl)

getMediaFunctions = ->
  requiredFunctions = ['pickLocalFile', 'capturePhoto', 'captureAudio', 'captureVideo']
  if Meteor.isCordova
    CordovaMedia
  else
    WebMedia

