# script/rockdove_server
#!/usr/bin/env ruby

# Run this file as ruby ./script/rockdove_server.rb start

require File.dirname(__FILE__) + '/../config/environment'
require "rubygems"
require "rockdove"
require "raad"

class RockdoveServer
  def initialize
    Rockdove::Follow::Ready.configure do |config| 
      config.ews_url 'https://ewsdomain.com/ews/exchange.asmx'
      config.ews_username 'ews_username'
      config.ews_password 'ews_password'
      config.ews_folder 'Inbox'
      #config.ews_move_folder 'Archive'
      #config.ews_watch_interval 60
    end
    #Raad.env = "production"
  end

  def start
    Raad::Logger.debug("Rockdove Daemon started in #{Raad.env} env")    
    process_rockdove_job    
  end

  def stop
    Raad::Logger.debug("Rockdove Daemon stopped")
  end

  def process_rockdove_job
    Rockdove::Follow::Action.watch do |parsed_mail|
      begin
        #Model.method(parsed_mail)
      rescue Exception => e
        Rockdove.logger.error "Exception occurred while receiving message:\n#{parsed_mail}"
        Rockdove.logger.error [e, *e.backtrace].join("\n")
      end
    end
  end
end

