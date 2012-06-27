# script/rockdove_server
#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "rockdove"

Rockdove::Follow::Ready.configure do |config| 
  config.ews_url 'https://ewsdomain.com/ews/exchange.asmx'
  config.ews_username 'ews_username'
  config.ews_password 'ews_password'
  config.ews_folder 'Inbox'
  #config.ews_move_folder 'Archive'
  #config.ews_watch_interval 60
end

Rockdove::Follow::Action.watch do |parsed_mail|
  begin
    #Model.method(parsed_mail)
  rescue Exception => e
    Rockdove.logger.error "Exception occurred while receiving message:\n#{message}"
    Rockdove.logger.error [e, *e.backtrace].join("\n")
  end
end