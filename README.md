rockdove ![rockdove](http://kiran.gnufied.org/wp-content/uploads/2012/07/1341725724_bird.png) [![Build Status](https://secure.travis-ci.org/kiranh/rockdove.png?branch=master)](http://travis-ci.org/kiranh/rockdove)
========

Incoming mail processing daemon for Exchange Web Services 1.0 (EWS). This Ruby Gem connects to the EWS mailbox, fetches the mail items, parses each mail item (Signatures, Replies, Forward), handles bounce types (Undeliverable,AutoReply) and polls the mailbox for every interval specified. 

It provides a template of the rockdove server which is a simple plug and play daemon.

## Installation

  ```ruby
  #Under Gemfile
  
  gem "rockdove", "~> 0.3.1", :require => false

  #After bundle install, run this command below
  bundle exec rails g rockdove:install
  ```
  It copies a template of rockdove server under you script folder which contains the following snippet:

  ```ruby
  
  # ...
  
  Rockdove::Config.configure do |config| 
    config.ews_url 'https://ewsdomain.com/ews/exchange.asmx'
    config.ews_username 'ews_username'
    config.ews_password 'ews_password'
    config.ews_folder 'Inbox' # ews_folder is Inbox by default
    # by default, it deletes the mail after processing, 
    # mention ews_archive_folder if it has to be archived to a different folder
    config.ews_archive_folder 'Archive'
    config.ews_watch_interval 60 # by default, the polling interval is 60
  end
  
  # ...

  Rockdove::CollectMail.watch do |rockdove_parsed_mail|
    begin
      Model.method(rockdove_parsed_mail)
      # As per your application requirements, refer the options that you can play with here,
      # http://rdoc.info/github/kiranh/rockdove/Rockdove/ExchangeMail
    rescue Exception => e
      Rockdove.logger.error "Exception occurred while receiving message:#{rockdove_parsed_mail}"
      Rockdove.logger.error [e, *e.backtrace].join("\n")
    end
  end

  ```
  You need to change the Model into the one being used in your project that would require this behavior of Mail Processing for Exchange Web Services 1.0 and further process the mail as per the requirements in your project.

  - And then you can run the script in console mode, `^C` will stop it, calling the stop method

  ``` sh
  $ ruby ./script/rockdove_server.rb start #from your project root
  ```
  - or run it daemonized, by default `./rockdove_server.log` and `./rockdove_server.pid` will be created

  ``` sh
  $ ruby ./script/rockdove_server.rb  -d start
  ```

  - you can stop the daemon, removing `./rockdove_server.pid` or
  
  ``` sh
  $ ruby ./script/rockdove_server.rb stop
  ```
  ---

## Compatibility

  Tested on all Ruby versions (1.8.7, 1.9.2, 1.9.3) with Travis CI. 

## Contributors

 Welcome for any code optmizations or issue fixes or enhancements

### Setup:

  ```ruby
    git clone git@github.com:kiranh/rockdove.git
    cd rockdove
    bundle exec rake # to run tests or bundle exec guard
  ```

## Acknowledgements

  To [Biju Shoolapani](https://github.com/bijushoolapani) for support and encouragement. And the Code Reviewer, [Hemant Kumar](http://github.com/gnufied).

## Copyright

Copyright (c) 2012-2015 Kiran Soumya Bosetti. See LICENSE for details.
