Template.newCheckout.events
  'click #newCheckout': (e, tmpl) ->
    cats = _.uniq Inventory.find({}, {'category': 1}).map (x) ->
      return {id: x._id, text:x.category}
    $select = $('#category').selectize
      create: true
      maxItems: 1,
      valueField: 'text',
      labelField: 'text',
      searchField: 'text',
      options: cats
  'click #submitItem': (e, tmpl) ->
    addItem(e, tmpl)
  'keypress .itemInput': (e, tmpl) ->
    if (e.charCode == 13) 
      addItem(e, tmpl)
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
  #TODO: Check and see if everything is cool. "Name", "description", "category" are definitely required; probably image too.
  name = tmpl.find('input[name=name]').value
  description = tmpl.find('input[name=description]').value
  serialNo = tmpl.find('input[name=serialNo]').value
  propertyTag = tmpl.find('input[name=propertyTag]').value
  category = tmpl.find('#category').value
  image = "test"
  barcode = tmp.find('input[name=barcode]').value
  $('#newCheckout').modal('toggle')


  _id = Inventory.insert
    name: name
    description: description
    serialNo: serialNo
    propertyTag: propertyTag
    category: category
    image: image
    barcode: barcode




getMediaFunctions = ->
  requiredFunctions = ['pickLocalFile', 'capturePhoto', 'captureAudio', 'captureVideo']
  if Meteor.isCordova
    CordovaMedia
  else
    WebMedia

