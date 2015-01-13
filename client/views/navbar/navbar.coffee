Template.navBar.events
  'click #logout': ->
    Meteor.logout()

#This is fairly junk code to produce helper collections for meteor-autocomplete.
#Until I know of a better way to only have autocomplete return unique selections from each field, these approximate that behavior.
Help = new Mongo.Collection(null)
Help.insert {name: ""}
Status = new Mongo.Collection(null)
Status.insert {status: "Any"}
Status.insert {status: "Available"}
Status.insert {status: "Unavailable"}


Template.navBar.helpers
  settings: ->
    return {
      position: "bottom"
      limit: 3
      rules: [
        {
          token: '@'
          collection: Inventory
          field: "assignedTo"
          template: Template.searchTokenAssigned
          callback: (doc, element) ->
            filters = Session.get "filters"
            filters.push('@.' + doc.assignedTo)
            Session.set "filters", filters
            $('#textSearch').val('')
        }
        {
          token: '!help'
          collection: Help
          field: "name"
          template: Template.searchHelp
          selector: () ->
            return ""
        }
        {
          token: '#'
          collection: Inventory
          field: "category"
          matchAll: true
          template: Template.searchTokenCategory
          callback: (doc, element) ->
            filters = Session.get "filters"
            filters.push("#." + doc.category)
            Session.set "filters", filters
            $('#textSearch').val('')
        }
        {
          token: 'name:'
          collection: Inventory
          field: "name"
          matchAll: true
          template: Template.searchFields
          selector: (match) ->
            regex = new RegExp match, 'i'
            return $or: [{'name': regex}, {'barcode': regex}]
          callback: (doc, element) ->
            filters = Session.get "filters"
            filters.push('name.' + doc.name)
            Session.set "filters", filters
            $('#textSearch').val('')
        }
        {
          token: 'status:'
          collection: Status
          field: "status"
          matchAll: true
          template: Template.searchTokenStatus
          callback: (doc, element) ->
            Session.set "availableFilter", doc.status
            $('#textSearch').val('')
        }
      ]
    }
