Template.sidebar.helpers
  categories: ->
    cats = _.uniq Inventory.find().fetch().map (x) ->
      return x.category
    return cats
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
            Session.set "textFilter", {type: "assignedTo", text: doc.assignedTo}
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
            Session.set "textFilter", {type: "name", text: doc.name}
        }
        {
          token: '#'
          collection: Inventory
          field: "category"
          matchAll: true
          template: Template.categoryTokenSearch
          callback: (doc, element) ->
            Session.set "textFilter", {type: "category", text: doc.category}
        }
      ]
    }

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
    Session.set "categoryFilter", catFilter

  'change .textSearch': (e, tmpl) ->
    Session.set "textFilter", $(e.target).val()

