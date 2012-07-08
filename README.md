rockdove ![rockdove](http://kiran.gnufied.org/wp-content/uploads/2012/07/1341725724_bird.png)
========

Incoming mail processing daemon for Exchange Web Services 1.0 (EWS). This Ruby Gem will fetch the mail, parse it and polls the mailbox for the interval specified for further processing in your Rails Project. Its a simple plug and play daemon.


## Installation

  ```ruby
  #Under Gemfile
  gem 'rockdove', :require => false

  #After bundle install, run this command below
  bundle exec rails g rockdove:install
  ```
  It copies a template of rockdove server under you script folder which contains the following snippet:
  ```ruby
  Rockdove::Follow::CollectMail.watch do |parsed_mail|
    begin
      #RailsModel.method(parsed_mail)
    rescue Exception => e
      Rockdove.logger.error "Exception occurred while receiving message:\n#{parsed_mail}"
      Rockdove.logger.error [e, *e.backtrace].join("\n")
    end
  end
  ```
  You need to change the RailsModel into the one being used in your project that would require this behavior of Mail Processing for Exchange Web Services 1.0 and further process the mail as per the requirements in your project.

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

  Tested on all Ruby versions with Travis CI. 

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
