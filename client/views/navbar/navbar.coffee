Template.navBar.events
  'click #logout': ->
    Meteor.logout()
  'click [data-action=setAvailableFilter]': (e, tmpl) ->
    Session.set "availableFilter", $(e.target).data('item')
  'change .categoryBox': (e, tmpl) ->
    filters = Session.get "filters"
    if e.target.checked
      filters.push "#." + $(e.target).data('item')
    else
      index = filters.indexOf('#.' + $(e.target).data('item'))
      filters.splice(index,1)
    Session.set "filters", filters

Template.navBar.helpers
  category: ->
    cats = _.uniq Inventory.find().fetch().map (x) ->
      return x.category
    filters = Session.get "filters"
    array = []
    cats.map (x) ->
      if ("#" + x) in filters
        array.push {name: x, checked: "checked"}
      else
        array.push {name: x, checked: null}
    return array

  availableFilter: -> Session.get "availableFilter"

Template.navBar.rendered = ->
  $(document).on 'click', '.yamm .dropdown-menu', (e) ->
    e.stopPropagation()
