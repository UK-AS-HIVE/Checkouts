Template.checkoutDialog.events
    'click #submitButton': (e, tmpl) ->
      #Putting this all into one button might make things a bit tough on readability.
      name = tmpl.find('input[name=searchFields]').value
      if $('#submitButton').html() is 'Check Out'
        now = new Date()
        assignedTo = tmpl.find('input[name=codAssignedTo]').value
        if assignedTo is ""
          alert "You must assign the item to someone."
        else
          #TODO: Verify assingedTo is acceptable.
          expectedReturn = tmpl.find('input[name=codDatepicker]').value
          #The datepicker control keeps expectedReturn acceptable. Thanks, datepicker!
          if new Date(expectedReturn) < now
            alert("Expected return date must be after today.")
          else
            #We're trusting the name, as the submit button only becomes available when selecting from autocomplete.
            Meteor.call "checkOutItem", name, assignedTo, expectedReturn
            $('#checkoutDialog').modal('toggle')
            resetFields tmpl
      else if $('#submitButton').html() is 'Check In'
        Meteor.call "checkInItem", name
        $('#checkoutDialog').modal('toggle')
        resetFields tmpl

    'click #cancelButton': (e, tmpl) ->
      resetFields tmpl

    'keyup': (e, tmpl) ->
      if e.keyCode is 27
        $('#checkoutDialog').modal('toggle')
        resetFields tmpl

Template.checkoutDialog.rendered = ->
  $('#codDatepicker').datepicker()

Template.checkoutDialog.helpers
  settings: {
    position: 'top'
    limit: 3
    rules: [
      {
        collection: Inventory
        template: Template.searchFields
        matchAll: true
        field: 'name'
        selector: (match) ->
          regex = new RegExp match, 'i'
          return $or: [{'name': regex}, {'barcode': regex}]
        callback: (doc, element) ->
          fillFields(doc)
      }
    ]
  }

resetFields = (tmpl) ->
  #Re-hide our rows and the submit button and clear the search field.
  tmpl.$("tr.hiddenRow").hide()
  $('#submitButton').hide()
  $('#searchFields').val('')

fillFields = (item) ->
  $('#codDescription').val(item.description)

  if item.assignedTo
    $('#codAssignedTo').val(item.assignedTo)
    $('#codAssignedTo').css('color', 'red')
    $('#codAssignedTo').attr("disabled", "disabled")
    $('#codDatepicker').val(item.schedule.expectedReturn)
    $('#codDatepicker').css('color','red')
    $('#codDatepicker').attr("disabled","disabled")
    $('#codAssignedToLabel').html('Assigned To:')
    $('#submitButton').html('Check In')

  else
     $('#codAssignedTo').val('')
     $('#codAssignedTo').css('color', 'black')
     $('#codAssignedTo').attr("disabled",false)
     $('#codDatepicker').val('')
     $('#codDatepicker').css('color','black')
     $('#codDatepicker').attr("disabled",false)
     $('#codAssignedToLabel').html('Assign To:')
     $('#submitButton').html('Check Out')

  $('#checkoutDialog').find(":hidden").show()

