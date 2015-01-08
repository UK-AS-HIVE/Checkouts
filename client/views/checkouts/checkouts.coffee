Template.checkouts.helpers
  checkoutItem: ->
    catFilter = Session.get("categoryFilter")
    if catFilter == "" or catFilter.length is 0
      catFilter = _.uniq Inventory.find().fetch().map (x) ->
        return x.category
    availableFilter = Session.get("availableFilter")
    switch availableFilter
      when "All"
        return Inventory.find {category: {$in: catFilter}}
      when "Available"
        return Inventory.find {category: {$in: catFilter}, assignedTo: ""}
      when "Unavailable"
        return Inventory.find {category: {$in: catFilter}, assignedTo: {$not: ""}}


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



