Template.newCheckout.events
  'click #submitItem': (e, tmpl) ->
    addItem(e, tmpl)
  'keypress .itemInput': (e, tmpl) ->
    if (e.charCode == 13) 
      addItem(e, tmpl)

Template.newCheckout.rendered = ->
  #TODO: Why does selectize not pick up any of our categories from the template? 
  #Tried putting it in via this script but the find doesn't work.
  cats = _.uniq Inventory.find({}, {'category': 1}).fetch().map (x) ->
      return x.category
  console.log cats
  $('#category').selectize
    create: true
    sortField: 'text'
    options: cats

addItem = (e, tmpl) ->
  #TODO: Check and see if everything is cool. "Name", "description", "category" are definitely required; probably image too.
  name = tmpl.find('input[name=name]').value
  description = tmpl.find('input[name=description]').value
  serialNo = tmpl.find('input[name=serialNo]').value
  propertyTag = tmpl.find('input[name=propertyTag]').value
  category = "test"
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

