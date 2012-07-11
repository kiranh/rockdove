module Rockdove
  class Config
    class << self
      attr_accessor :url, :username, :password, :incoming_folder, :archive_folder, :watch_interval, :ignore_mails
    end

    def self.configure(&block)
      block.call(self)
      connect
    end

    def self.ews_url(value)
      @url = value
    end

    def self.ews_username(value)
      @username = value
    end

    def self.ews_password(value)
      @password = value
    end

    def self.ews_folder(value)
      @incoming_folder = value || 'Inbox'
    end

    def self.ews_archive_folder(value)
      @archive_folder = value
    end

    def self.ews_watch_interval(value)
      @watch_interval = value || 60
    end

    def self.ews_ignore_mails(value)
      @ignore_mails = value || []
    end

    def self.connect
      Viewpoint::EWS::EWS.endpoint = @url
      Viewpoint::EWS::EWS.set_auth @username, @password
      Viewpoint::EWS::EWS.instance
    end
  end
end
