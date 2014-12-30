
Template.newCheckout.events
  'click #submitItem': (e, tmpl) ->
    addItem(e, tmpl)
  'keypress .itemInput': (e, tmpl) ->
    if (e.charCode == 13) 
      addItem(e, tmpl)

Template.newCheckout.helpers
  category: ->
    _.uniq Inventory.find({}, {'category':1}).fetch().map (x) ->
      return x.category

Template.newCheckout.rendered = ->
  #This doesn't work, and I'm not sure it ever will.
  #$("#category").selectize()

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

