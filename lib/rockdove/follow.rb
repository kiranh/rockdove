require "rockdove/exchange_mail"
module Rockdove
  module Follow
    class Ready
      class << self
        attr_accessor :url, :username, :password, :incoming_folder, :move_folder, :watch_interval
      end
      #
      # This class handles the configuration ready part of Rockdove.
      # It takes in the Exchange Server details along with authentication and the folder details.
      #
      def self.configure( &block )
        block.call( self )
        connect
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

      def self.ews_watch_interval( value )
        @watch_interval = value || 60
      end

      def self.connect
        Rockdove.logger.info "Rockdove is trying to connect to Exchange Server..."
        Viewpoint::EWS::EWS.endpoint = @url
        Viewpoint::EWS::EWS.set_auth @username, @password
      end
    end

    class Action
      #
      # This class handles the action part of Rockdove for mail retrieval, parsing and watch on the mailbox based on the interval.
      #
      #Rockdove::Follow::Action.watch do |parsed_message|
      #  Post.process_this_mail(parsed_message)
      #end
      def self.watch
        loop do
          begin
            Rockdove.logger.info "Rockdove on watch for new mail ... "
            mail_retriever = Rockdove::Follow::Action.new()
            parsed_message = mail_retriever.retrieve_mail()
            if parsed_message
              yield(parsed_message)
              Rockdove::Follow::PackUp.new().process
            end
          rescue Exception => e
            Rockdove.logger.info(e)
          ensure
            sleep(Rockdove.watch_interval)
          end
        end
      end

      def retrieve_mail
        fetched_mail = fetch_from_box
        return false unless fetched_mail
        Rockdove.logger.info "Rockdove collected the mail"
        Rockdove::ExchangeMail.new(fetched_mail)
      end

      def fetch_from_box
        return nil if inbox.nil?
        mail_stack = inbox.find_items 
        return nil if mail_stack.empty?
        inbox.get_item(mail_stack.first.id)
      end

      def inbox
        @incoming_folder = Rockdove::Follow::Ready.incoming_folder
        Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder)
      rescue
        reconnect_and_raise_error
      end

      def reconnect_and_raise_error
        Rockdove.logger.info "Reconnecting to the Exchange Server & Fetching the Mail now..."
        Rockdove::Follow::Ready.connect
        Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder) 
      rescue Viewpoint::EWS::EwsError
        send_connection_failed_message
      end

      def send_connection_failed_message
        Rockdove.logger.info "Unable to connect to the Exchange Server"
        return nil
      end
    end

    class PackUp
      #
      # This class handles the packup part of Rockdove for the final process of archiving or deleting the processed mail.
      #
      def process
        item = Rockdove::Follow::Action.raw_item
        to_folder = Rockdove::Follow::Ready.move_folder
        if to_folder.blank?
          item.delete!
          Rockdove.logger.info "Rockdove delivered the Mail..."
        else
          item.move!(to_folder)
          Rockdove.logger.info "Rockdove delivered & archived the Mail..."
        end
      end
    end
  end
end