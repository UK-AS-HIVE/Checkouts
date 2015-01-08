Checkouts
==
##Overview##
A Meteor.js application for inventory management and checkouts.

##Installation##
Clone the repo, clone hive:accounts-ldap into the packages/ directory, and run the command `meteor --settings settings.json`. It's possible that some of this could be abstracted in the future to allow for different login handlers. You'll need to set LDAP settings in settings.json if you want to use a different LDAP server for login.
* git clone https://github.com/UK-AS-HIVE/Checkouts
* cd Checkouts
* mkdir -p packages
* git clone https://github.com/UK-AS-HIVE/meteor-accounts-ldap packages/hive:accounts-ldap
* meteor --settings settings.json

##Usage##
Out of the box, administrator privileges are determined by SG membership (see `client/lib/helpers.coffee`). Administrators can create and inventory items, and other users should be able to log in and browse the inventory. Updating and deleting objects and most non-administrative functionality is forthcoming.
