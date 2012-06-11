require 'viewpoint'
require "rockdove/version"
require "rockdove/dove_parser"
require "rockdove/dovetie" if defined?(Rails)

module Rockdove
  
  class Ready 
    class << self
      attr_accessor :url, :username, :password, :incoming_folder, :move_folder, :poll_interval
    end

    def self.configure( &block )
      block.call( self )
    end

    def self.ews_url( value )
      @url = value
    end

    def self.ews_username( value )
      @username = value
    end

    def self.ews_password( value )
      @password = value
    end

    def self.ews_folder( value )
      @incoming_folder = value || 'Inbox'
    end

    def self.ews_move_folder( value )
      @move_folder = value || 'Archive'
    end

    def self.ews_poll_interval( value )
      @poll_interval = value || 60
    end

    def self.connect
      Viewpoint::EWS::EWS.endpoint = @url
      Viewpoint::EWS::EWS.set_auth @username, @password
    end

    def self.retrieve_mail
      dove_mail = Hash.new
      self.connect()
      inbox = Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder)
      all_mails  = inbox.find_items
      if(all_mails.length > 0)
        item = inbox.get_item(msgs.first.id)
        collect_stuff(item) if item
      end
      return dove_mail
    end

    def collect_stuff(mail)
      dove_mail[:from] = mail.from.email_address
      dove_mail[:to] = mail.to_recipients.collect &:email_address if mail.to_recipients
      dove_mail[:cc] = mail.cc_recipients.collect &:email_address if mail.cc_recipients
      dove_mail[:subject] = mail.subject.strip
      dove_mail[:body] = Rockdove::DoveParser.parse_mail(mail.body) if mail.body.length > 0
      dove_mail[:datetime_sent] = mail.date_time_sent
      dove_mail[:datetime_created] = mail.date_time_created
      dove_mail[:has_attachments?] = mail.has_attachments?
      return dove_mail
    end
    
  end

  class Action 
    #Rockdove.poll do |parsed_message|
    #  Post.process_this_mail(parsed_message)
    #end

    def poll
      loop do
        begin
          parsed_message = Rockdove::Ready.retrieve_mail
          yield(parsed_message) if parsed_message,values.any?
        rescue Exception => e
          Rockdove.logger.info(e)
        ensure
          sleep(Rockdove.poll_interval)
        end
      end
    end

  end

end
