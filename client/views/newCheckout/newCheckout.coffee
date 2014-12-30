Template.newCheckout.events
  'click #submitItem': (e, tmpl) ->
    addItem(e, tmpl)
  'keypress .itemInput': (e, tmpl) ->
    if (e.charCode == 13) 
      addItem(e, tmpl)

Template.newCheckout.rendered = ->
  cats = _.uniq Inventory.find({}, {'category': 1}).map (x) ->
      return {id: x._id, text:x.category}
  console.log cats
  $select = $('#category').selectize
    create: true
    maxItems: 1,
    valueField: 'text',
    labelField: 'text',
    searchField: 'text',
    options: cats

addItem = (e, tmpl) ->
  #TODO: Check and see if everything is cool. "Name", "description", "category" are definitely required; probably image too.
  name = tmpl.find('input[name=name]').value
  description = tmpl.find('input[name=description]').value
  serialNo = tmpl.find('input[name=serialNo]').value
  propertyTag = tmpl.find('input[name=propertyTag]').value
  category = tmpl.find('#category').value
  image = "test"
  barcode = "test"
  $('#newCheckout').modal('toggle')


  _id = Inventory.insert
    name: name
    description: description
    serialNo: serialNo
    propertyTag: propertyTag
    category: category
    image: image
    barcode: barcode

