Template.sidebar.helpers
  filters: ->
    filters = Session.get("filters")
    for filter in filters
      index = filter.indexOf('.')
      type = filter.substr(0,index)
      text = filter.substr(index+1)
      switch type
        when "#"
          obj = {type: "category", text: text, id: filter}
        when "@"
          obj = {type: "assignedTo", text: text, id: filter}
        when "name"
          obj = {type: "name", text: text, id: filter}

  availableFilter: ->
    return Session.get "availableFilter"
Template.sidebar.events
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
