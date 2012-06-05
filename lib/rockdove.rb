require 'viewpoint'
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
  	  Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder)
  	end
  end

end
