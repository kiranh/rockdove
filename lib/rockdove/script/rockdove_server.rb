# script/rockdove_server
#!/usr/bin/env ruby

# Run this file as ruby ./script/rockdove_server.rb start

require File.dirname(__FILE__) + '/../config/environment'
require "rubygems"
require "rockdove"
require "raad"

class RockdoveServer
  def initialize
    Rockdove::Config.configure do |config| 
      # (EDIT THIS CONTENT BELOW)
      config.ews_url 'https://ewsdomain.com/ews/exchange.asmx'
      config.ews_username 'ews_username'
      config.ews_password 'ews_password'
      config.ews_folder 'Inbox' # ews_folder is Inbox by default
      config.ews_archive_folder 'Archive' # by default, it deletes the mail after processing, mention ews_archive_folder if it 
      # has to be archived to a different folder
      config.ews_watch_interval 60 # by default, the polling interval is 60
      config.ews_ignore_mails ["postmaster@ewsdomain.com"] # an array of emails to be ignored
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
    Rockdove::CollectMail.watch do |rockdove_parsed_mail|
      begin
        #Model.method(rockdove_parsed_mail) (EDIT THIS)
      rescue Exception => e
        Rockdove.logger.error "Exception occurred while receiving message:\n#{rockdove_parsed_mail}"
        Rockdove.logger.error [e, *e.backtrace].join("\n")
      end
    end
  end
end

