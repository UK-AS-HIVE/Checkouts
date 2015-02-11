Template.checkouts.helpers
  checkoutItem: ->
    #For the moment, I'm leaving the filter parsing logic in here. It might be unnecessary if we don't reintroduce a text search.
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
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: null}
      when "Unavailable"
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: {$not: null}}
      else
        return Inventory.find {category: {$in: catFilter}, name: {$in: nameFilter}, assignedTo: {$in: assignedToFilter}}
  isAdmin: -> return isAdmin(Meteor.user().id)

Template.checkouts.events
  'click button[data-action=checkoutByBarcode]': ->
    result = cordova.plugins.barcodeScanner.scan (res, err) ->
      if res
        item = Inventory.findOne {barcode: res.text}
        if item?
          Session.set "checkoutItem", item
        else
          Session.set "checkoutError", "Item not found. Try searching by name or barcode number."
      else
        console.log err
        Session.set "checkoutError", "Error in scanning barcode. Try searching by name or barcode number."
      $('#checkoutDialog').modal('show')

  'click button[data-action=reserve]': (e, tmpl) ->
    id = $(e.target).data("item")
    Session.set "reserveItem", Inventory.findOne({_id: id})
    $('#reserveDialog').modal('toggle')

  'click button[data-action=checkout]': (e, tmpl) ->
    id = $(e.target).data("item")
    Session.set "checkoutItem", Inventory.findOne({_id: id})
    $('#checkoutDialog').modal('toggle')

  'click button[data-action=edit]': (e, tmpl) ->
    id = $(e.target).data("item")
    Session.set "editCheckoutItem", Inventory.findOne({_id: id})
    $('#itemDialog').modal('toggle')

  'click button[data-action=delete]': (e, tmpl) ->
    id = $(e.target).data("item")
    Session.set "deleteItem", Inventory.findOne({_id: id})
    $('#deleteItem').modal('toggle')

  'click button[data-action=cancelReserve]': (e, tmpl) ->
    if $(e.target).html() is "Cancel Reservation"
      $(e.target).html("Click again to confirm")
    else if $(e.target).html() is "Click again to confirm"
      Meteor.call "cancelReservation", $(e.target).data("item")

  'click button[data-action=checkoutLog]': (e, tmpl) ->
    item = Inventory.findOne {_id: $(e.target).data("item")}
    Session.set "checkoutLogItem", item
    $('#checkoutLog').modal('show')

  'shown.bs.collapse': (e, tmpl) ->
    #Change the plus to a minus and vice-versa on row expand and collapse."
    id = $(e.target).attr('name')
    tmpl.$('span[name='+id+']').removeClass('glyphicon-plus').addClass('glyphicon-minus')

  'hidden.bs.collapse': (e, tmpl) ->
    id = $(e.target).attr('name')
    tmpl.$('span[name='+id+']').removeClass('glyphicon-minus').addClass('glyphicon-plus')

Template.checkoutRow.helpers
  rootUrl: ->
    if Meteor.isCordova
      __meteor_runtime_config__.ROOT_URL.replace(/\/$/, '') + __meteor_runtime_config__.ROOT_URL_PATH_PREFIX
    else
      __meteor_runtime_config__.ROOT_URL.replace /\/$/, ''
  thumbnailUrl: ->
    if @imageId
      item = FileRegistry.findOne {_id: @imageId}
      return item.thumbnail
    else
      return null
  isAdmin: -> return isAdmin(Meteor.user().id)
  dateReserved: ->
    if @reservation?.dateReserved
      return @reservation.dateReserved.getMonth()+1 + '/' + @reservation.dateReserved.getDate() + '/' + @reservation.dateReserved.getFullYear()
    else return null

  assignedToMe: ->
    if @reservation?.assignedTo is Meteor.user().username
      return true
    else
      return false
