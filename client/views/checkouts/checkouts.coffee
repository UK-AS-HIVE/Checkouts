Template.checkouts.helpers
  checkoutItem: ->
    catFilter = []
    nameFilter = []
    assignedToFilter = []
    for filter in Session.get "filters"
      type = filter.substr(0,1)
      switch type
        when "#"
          catFilter.push(filter.substr(1))
        when "!"
          nameFilter.push(filter.substr(1))
        when "@"
          assignedTo.push(filter.substr(1))
    if catFilter.length is 0
      catFilter = _.uniq Inventory.find().fetch().map (x) ->
        return x.category
    if nameFilter.length is 0
      nameFilter = _.uniq Inventory.find().fetch().map (x) ->
        return x.name
    availableFilter = Session.get("availableFilter")
    switch availableFilter
      when "All"
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}}
      when "Available"
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: ""}
      when "Unavailable"
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: {$not: ""}}
      else
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: {$in: assignedToFilter}}


  isAdmin: -> return isAdmin(Meteor.user().id)

Template.checkouts.events
  'click #checkOutButton': ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        openCheckoutDialog(res.text)
      else
        alert("Error in scanning barcode.") #Make this meaningful.

  'click .accordion-toggle': (e, tmpl) ->
    if $(e.target).closest("tr").find("td:first").html() is '<span class="glyphicon glyphicon-minus"></span>'
      $(e.target).closest("tr").find("td:first").html('<span class="glyphicon glyphicon-plus"></span>')
    else
      $(e.target).closest("tr").find("td:first").html('<span class="glyphicon glyphicon-minus"></span>')

  'click .checkoutItemBtn': (e, tmpl) ->
    item = Inventory.findOne {name: e.target.id}
    Session.set "codItem", item
    $('#checkoutDialog').modal('toggle')

