require 'viewpoint'
require "rockdove/version"
require "rockdove/dove_parser"
require "rockdove/dovetie" if defined?(Rails)

module Rockdove
  
  class Ready 
    class << self
      attr_accessor :url, :username, :password, :incoming_folder, :move_folder
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
        Rockdove::DoveParser.parse_mail(mail)
      end
    
  end

end
