Template.checkouts.helpers
  checkoutItem: ->
    catFilter = Session.get("categoryFilter")
    if catFilter.length == 0
      catFilter = _.uniq Inventory.find().fetch().map (x) ->
        return x.category
    availableFilter = Session.get("availableFilter")
    textFilter = Session.get("textFilter")
    nameFilter = /./
    switch textFilter.type
      when "category"
        catFilter = []
        catFilter.push(textFilter.text)
      when "name"
        nameFilter = textFilter.text
      when "assignedTo"
        availableFilter = textFilter.text
    console.log catFilter
    switch availableFilter
      when "All"
        return Inventory.find {category: {$in: catFilter}, name: {$regex: nameFilter, $options: 'i'}}
      when "Available"
        return Inventory.find {category: {$in: catFilter}, name: {$regex: nameFilter, $options: 'i'}, assignedTo: ""}
      when "Unavailable"
        return Inventory.find {category: {$in: catFilter}, name: {$regex: nameFilter, $options: 'i'}, assignedTo: {$not: ""}}
      else
        return Inventory.find {category: {$in: catFilter}, name: {$regex: nameFilter, $options: 'i'}, assignedTo: {$regex: availableFilter, $options: 'i'}}


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



