Template.deleteItemDialog.helpers
  item: -> return Session.get "deleteItem"

Template.deleteItemDialog.events
  'click [data-action=cancelDeleteItem]': ->
    Session.set "deleteItem", null
  'click [data-action=deleteItem]': ->
    item = Session.get "deleteItem"
    #Maybe just put both of these in the same method?
    Meteor.call "addDeletedItem", item
    Inventory.remove {_id: item._id}
    Session.set "deleteItem", null
    $('#deleteItem').modal('toggle')
