Meteor.methods
  checkOutItem: (id, username, expectedReturn) ->
    now = new Date()
    #In addition to checking out the item, we nullify any reservation. This might not be ideal.
    item = Inventory.update {_id: id}, {$set:
      assignedTo: username
      timeCheckedOut: now
      expectedReturn: expectedReturn,
      reservation: null
    }
    console.log item 
    #Email to confirm checkout.
    emailBody = "<p>Your item checkout is confirmed:</p>
      <h3>#{item.name}</h3>
      <p>Checked out on: #{moment(item.timeCheckedOut).format('dddd, MMMM Do YYYY')}</p>"
    
    if item.expectedReturn
      emailBody = emailBody + "<p>Expected Return: #{moment(item.expectedReturn).format('dddd, MMMM Do YYYY')} </p>"

    checkoutDetails =
      username: item.assignedTo
      subject: "Confirmation of your A&S Reservation"
      html: emailBody
    sendMail(checkoutDetails)
     
    #Schedule an email for return time if one is expected.
    if item.expectedReturn?
      returnDetails =
        username: item.assignedTo
        subject: "Your A&S Reservation is Due"
        html: "<p>Your item checkout is due:</p>
              <h3>#{item.name}</h3>
              <p>Checked out on: #{moment(item.timeCheckedOut).format('dddd, MMMM Do YYYY')}</p>
              <p>Expected Return: #{moment(item.expectedReturn).format('dddd, MMMM Do YYYY')}</p>
              <p>Please return the item to POT 915 at your convenience.</p>"

        date: moment(item.expectedReturn).subtract(1, 'days').hours(17).minutes(0).seconds(0) #One day before expected return at 5pm. 

      scheduleMail(returnDetails)

  checkInItem: (id) ->
    now = new Date()
    item = Inventory.findOne {_id: id}
    
    details =
      username: item.assignedTo
      subject: "A&S Checkouts: Item Checked In"
      html: "Your item has been returned:</p>
      <h3>#{item.name}</h3>
      <p>Checked out on: #{moment(item.timeCheckedOut).format('dddd, MMMM Do YYYY')}</p>
      <p>Checked in on: #{moment(now).format('dddd, MMMM Do YYYY')}</p>"
      
    sendMail(details)

    if item.checkoutLog
      item.checkoutLog.push {
        timeCheckedOut: item.timeCheckedOut
        timeCheckedIn: now
        assignedTo: item.assignedTo
      }
    else
      checkoutLog =[{
       timeCheckedOut: item.timeCheckedOut
       timeCheckedIn: now
       assignedTo: item.assignedTo
      }]

    Inventory.update {_id: id}, {$set: {
      assignedTo: null,
      timeCheckedOut: null
      expectedReturn: null
      checkoutLog: item.checkoutLog
    }}


  addItem: (itemObj) ->
    #This is done very explicitly due to errors in just inserting/updating objects.
    item = Inventory.insert
      name: itemObj.name
      description: itemObj.description
      serialNo: itemObj.serialNo
      propertyTag: itemObj.propertyTag
      category: itemObj.category
      imageId: itemObj.imageId
      barcode: itemObj.barcode

  addDeletedItem: (itemObj) ->
    DeletedInventory.insert itemObj

  reserveItem: (id, reservation) ->
    Inventory.update {_id: id}, {$set: {
      reservation:
        dateReserved: reservation.dateReserved
        expectedReturn: reservation.expectedReturn
        assignedTo: reservation.assignedTo
    }}
    
    #Instant email to confirm reservation.
    emailBody = "<p>Your item reservation is confirmed:</p>
      <h3>#{item.name}</h3>
      <p>Reserved for: #{moment(item.reservation.dateReserved).format('dddd, MMMM Do YYYY')}</p>"
    
    if item.reservation.expectedReturn
      emailBody = emailBody + "<p>Until: #{moment(item.reservation.expectedReturn).format('dddd, MMMM Do YYYY')} </p>"

    emailDetails =
      username: item.reservation.assignedTo
      subject: "Confirmation of your A&S Reservation"
      html: emailBody
    sendMail(emailDetails)
    
    #Send an email a day before reservation as a reminder.
    reservationBody = "<p>Your item reservation is soon:</p>
      <h3>#{item.name}</h3>
      <p>Reserved for: #{moment(item.reservation.dateReserved).format('dddd, MMMM Do YYYY')}</p>"
    
    if item.reservation.expectedReturn
      reservationBody = reservationBody + "<p>Until: #{moment(item.reservation.expectedReturn).format('dddd, MMMM Do YYYY')} </p>"

    reservationBody = reservationBody + "<p>Please pick up the item in POT 915 at your convenience.</p>"

    reservationDetails =
      username: item.reservation.assignedTo
      subject: "Your A&S Reservation"
      html: reservationBody
      date: moment(item.reservation.dateReserved).subtract(1, 'days').hours(17).minutes(0).seconds(0) #One day before expected return at 5pm. 

    scheduleMail(reservationDetails)

  cancelReservation: (id) ->
    id = Inventory.findOne {_id: id}
    emailDetails =
      username: item.reservation.assignedTo
      subject: "Your A&S reservation has been cancelled."
      html: "<p>Your item reservation has been cancelled:</p>
      <h3>#{item.name}</h3>
      <p>Reserved for: #{moment(item.reservation.dateReserved).format('dddd, MMMM Do YYYY')}</p>"

    sendMail(emailDetails)
    
    Inventory.update {_id: id}, {$set: {reservation: null}}

  checkUsername: (username) ->
    client = LDAP.createClient(Meteor.settings.ldap.serverUrl)
    LDAP.bind client, Meteor.settings.ldapDummy.username, Meteor.settings.ldapDummy.password
    result = LDAP.search client, username
    client.unbind()
    return result

#Server-side functions for sending emails.
FutureTasks = new Mongo.Collection 'futureTasks' #Server-side collection for storing jobs in case of reboot.
scheduleMail = (details) ->
  if details.date <  new Date()
    sendMail(details)
  else
    id = FutureTasks.insert(details)
    addTask(id, details)

addTask = (id, details) ->
  SyncedCron.add
    name: id
    schedule: (parser) ->
      parser.recur().on(details.date).fullDate()
    job: ->
      sendMail(details)
      FutureTasks.remove id
      SyncedCron.remove id

sendMail = (details) ->
  #Wrapper for Email.send.
  Email.send
    from: Meteor.settings.email.fromEmail
    to: details.username + "@" + Meteor.settings.email.emailDomain
    subject: details.subject
    html: details.html

Meteor.startup ->
  if not Meteor.settings.email
    throw new Error "Email settings missing."

