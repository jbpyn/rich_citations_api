Rich Citations API
==================
Live version: http://api.richcitations.org/

(c) 2014 PLOS Labs

Installing
==========
Requirements:
`Ruby 2.1.2`,`bundler`

```
$ cd rich_citations_api
$ bundle install
$ cp config/database.yml.example config/database.yml
$ bundle exec rake db:migrate
$ bundle exec rails server
```

Docker/Fig
==========

If you have docker and fig installed, you can use that to run the Rich
Citations API.

```
$ cd rich_citations_api
$ fig build
$ fig run web sudo su - app /bin/bash -c "cd /home/app/webapp && bundle exec rake secret"
# ^- write this down
$ SECRET_KEY_BASE=WHAT_YOU_WROTE_DOWN fig up
```

And to initialize the database, run this from another terminal:

```
$ fig run web sudo su - app /bin/bash -c "cd /home/app/webapp && bundle exec rake db:migrate"
```

Create a user:

```
$ fig run web sudo su - app /bin/bash -c "cd /home/app/webapp && bundle exec rake app:user:create name=MYNAME"
Created user: id:1: name:MYNAME
     api-key: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

Configurations
==============

To create a USER and API key run
rake app:user:create [name="full name"] [email=email]

