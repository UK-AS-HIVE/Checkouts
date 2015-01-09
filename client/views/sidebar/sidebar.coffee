Template.sidebar.helpers
  availableFilter: -> Session.get "availableFilter"
  category: ->
    #this is janky af. Get the category filters, get the categories, and then for each category check if its in category filters and check the box if so.
    catFilters = []
    filters = Session.get("filters")
    filters.map (x) ->
      if x.type is "category"
        catFilters.push x.text
    cats = _.uniq Inventory.find().fetch().map (x) ->
      return x.category
    array = []
    for cat in cats
      if cat in catFilters
        array.push {name: cat, checked: "checked"}
      else
        array.push {name: cat, checked: ""}
    return array
  filters: ->
    return Session.get("filters")
  settings: ->
    return {
      position: "bottom"
      limit: 3
      rules: [
        {
          token: '@'
          collection: Inventory
          field: "assignedTo"
          template: Template.assignedToTokenSearch
          callback: (doc, element) ->
            filters = Session.get "filters"
            filters.push({type: "assignedTo", text: doc.assignedTo})
            Session.set "filters", filters
            $('#textSearch').val('')
        }
        {
          token: '!'
          collection: Inventory
          field: "name"
          matchAll: true
          selector: (match) ->
            regex = new RegExp match, 'i'
            return $or: [{'name': regex}, {'barcode': regex}]
          template: Template.searchFields #Reusing the template from our earlier search.
          callback: (doc, element) ->
            filters = Session.get "filters"
            filters.push({type: "name", text: doc.name})
            Session.set "filters", filters
            $('#textSearch').val('')
        }
        {
          token: '#'
          collection: Inventory
          field: "category"
          matchAll: true
          template: Template.categoryTokenSearch
          callback: (doc, element) ->
            filters = Session.get "filters"
            filters.push({type: "category", text: doc.category})
            Session.set "filters", filters
            $('#textSearch').val('')
        }
        {
          token: 'status:'
        }
      ]
    }

Template.sidebar.events
  'click .availableBox': (e, tmpl) ->
    Session.set "availableFilter", e.target.id

  'change .categoryBox': (e, tmpl) ->
    #When checkboxes change, add or remove items from the filter array.
    filters = Session.get("filters")
    if e.target.checked
      filters.push({type: "category", text: e.target.name})
    else
      index = filters.indexOf({type: "category", text: e.target.id})
      filters.splice(index,1)
    Session.set "filters", filters

  'click .removeFilter': (e, tmpl) ->
    #TODO: Animate this a little?
    text = e.target.id
    tmpl.find('input[name='+text+']')
    filters = Session.get("filters")
    index = filters.indexOf(e.target.id)
    filters.splice(index,1)
    Session.set "filters", filters
