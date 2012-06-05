require 'viewpoint'
require 'email_reply_parser'
require "rockdove/version"
require "rockdove/dovetie" if defined?(Rails)

module Rockdove
  
  class Ready
  	attr_accessor :url, :username, :password, :incoming_folder, :move_folder

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
      @incoming_folder = value
    end

    def self.ews_move_folder( value )
      @move_folder = value
    end

    def self.connect
  	  Viewpoint::EWS::EWS.endpoint = @url
  	  Viewpoint::EWS::EWS.set_auth @username, @password
  	end

  	def self.retrieve_mail
  	  self.connect()
  	  inbox = Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder)
  	  all_mails  = inbox.find_items
  	  mail = inbox.get_item(all_mails.first.id) if all_mails
  	  mail
  	end

    def self.parse_mail(mail)
      text = mail.body.text
      EmailReplyParser.parse_reply(mail.sanitize!)
    end

  	
  end

end
