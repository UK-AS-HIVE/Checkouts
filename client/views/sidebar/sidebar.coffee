Template.sidebar.helpers
  categories: ->
    cats = _.uniq Inventory.find().fetch().map (x) ->
      return x.category
    return cats

Template.sidebar.events
  'click .availableBox': (e, tmpl) ->
    Session.set "availableFilter", e.target.id

  'change .categoryBox': (e, tmpl) ->
    #When checkboxes change, add or remove items from the filter array.
    catFilter = Session.get("categoryFilter") || []
    if e.target.checked
      catFilter.push(e.target.id)
    else
      index = catFilter.indexOf(e.target.id)
      catFilter.splice(index,1)
    Session.set("categoryFilter", catFilter)

