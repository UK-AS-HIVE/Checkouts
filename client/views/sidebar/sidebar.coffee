Template.sidebar.helpers
  availableFilter: -> Session.get "availableFilter"
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
    console.log array
    return array
  filters: ->
    filters = Session.get("filters")
    filters.map (x) ->
      type = x.substr(0,1)
      text = x.substr(1)
      switch type
        when "#"
          obj = {type: "category", text: text, id: x}
        when "!"
          obj = {type: "name", text: text, id: x}
        when "@"
          obj = {type: "assignedTo", text: text, id: x}
      return obj
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
            filters.push('@' + doc.assignedTo)
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
            filters.push('!' + doc.name)
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
            filters.push("#" + doc.category)
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
      filters.push('#' + e.target.name)
    else
      index = filters.indexOf('#' + e.target.name)
      filters.splice(index,1)
    Session.set "filters", filters

  'click .removeFilter': (e, tmpl) ->
    console.log e.target.id
    filters = Session.get("filters")
    index = filters.indexOf(e.target.id)
    filters.splice(index,1)
    Session.set "filters", filters

Template.sidebar.rendered = ->
  @$('.animated')[0]._uihooks = {
    insertElement: (node, next) ->
      $(node).addClass('off').insertBefore(next)

      Tracker.afterFlush ->
        $(node).removeClass('off')

    removeElement: (node) ->
      #These are events that are triggered at the end of a CSS transition. 
      finishEvent = 'webkitTransitionEnd
        oTransitionEnd
        transitionEnd
        msTransitionEnd
        transitionend'

      $(node).addClass('off')
      $(node).on finishEvent, ->
        $(node).remove()
  }
