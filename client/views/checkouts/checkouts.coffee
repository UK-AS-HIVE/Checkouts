Template.checkouts.helpers
  checkoutItem: ->
    catFilter = []
    nameFilter = []
    assignedToFilter = []
    for filter in Session.get "filters"
      index = filter.indexOf('.')
      type = filter.substr(0,index)
      switch type
        when "#"
          catFilter.push(filter.substr(index+1))
        when "name"
          nameFilter.push(filter.substr(index+1))
        when "@"
          assignedTo.push(filter.substr(index+1))
    if catFilter.length is 0
      catFilter = _.uniq Inventory.find().fetch().map (x) ->
        return x.category
    if nameFilter.length is 0
      nameFilter = _.uniq Inventory.find().fetch().map (x) ->
        return x.name
    availableFilter = Session.get("availableFilter")
    switch availableFilter
      when "Any"
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}}
      when "Available"
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: ""}
      when "Unavailable"
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: {$not: ""}}
      else
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: {$in: assignedToFilter}}


  isAdmin: -> return isAdmin(Meteor.user().id)

Template.checkouts.events
  'click .accordion-toggle': (e, tmpl) ->
    if $(e.target).closest("tr").find("td:first").html() is '<span class="glyphicon glyphicon-minus"></span>'
      $(e.target).closest("tr").find("td:first").html('<span class="glyphicon glyphicon-plus"></span>')
    else
      $(e.target).closest("tr").find("td:first").html('<span class="glyphicon glyphicon-minus"></span>')

  'click .checkoutItemBtn': (e, tmpl) ->
    id = $(e.target).data("item")
    item = Inventory.findOne {_id: id}
    Session.set "codItem", item
    $('#checkoutDialog').modal('toggle')

  'click .editItemBtn': (e, tmpl) ->
    id = $(e.target).data("item")
    item = Inventory.findOne {_id: id}
    Session.set "editCheckoutItem", item
    $('#newCheckout').modal('toggle')

  'click .deleteItemBtn': (e, tmpl) ->
    id = $(e.target).data("item")
    item = Inventory.findOne {_id: id}
    Session.set "deleteItem", item
    $('#deleteItem').modal('toggle')

Template.checkoutRow.helpers
  isAdmin: -> return isAdmin(Meteor.user().id)
