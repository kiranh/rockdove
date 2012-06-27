require "rockdove/exchange_mail"
module Rockdove
  module Follow
    class Ready
      class << self
        attr_accessor :url, :username, :password, :incoming_folder, :move_folder, :watch_interval
      end
    
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
        @move_folder = value 
      end

      def self.ews_watch_interval( value )
        @watch_interval = value || 60
      end

      def self.connect        
        Viewpoint::EWS::EWS.endpoint = @url
        Viewpoint::EWS::EWS.set_auth @username, @password
        Rockdove.logger.info "Rockdove connected to Exchange Server."
      end
    end

    class Action
      def self.watch
        loop do
          begin
            Rockdove.logger.info "Rockdove on watch for new mail..."
            mail_retriever = Rockdove::Follow::Action.new()
            parsed_mail = mail_retriever.retrieve_mail()
            if parsed_mail
              yield(parsed_mail)
              Rockdove::Follow::PackUp.new().process(mail_retriever)
            end
          rescue Exception => e
            Rockdove.logger.info(e)
          ensure
            sleep(Rockdove::Follow::Ready.watch_interval)
          end
        end
      end

      def retrieve_mail
        fetched_mail = fetch_from_box    
        return no_mail_alert unless fetched_mail          
        Rockdove.logger.info "Rockdove collected the mail."
        Rockdove::ExchangeMail.new(fetched_mail)
      end

      def no_mail_alert
        Rockdove.logger.info "Rockdove observed no mail yet."
        nil       
      end

      def fetch_from_box        
        return nil if inbox.nil? || inbox == true
        mail_stack = inbox.find_items 
        return nil if mail_stack.empty?
        inbox.get_item(mail_stack.first.id)
      end

      def inbox
        @incoming_folder = Rockdove::Follow::Ready.incoming_folder
        return Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder)       
      rescue
        reconnect_and_raise_error
      end

      def reconnect_and_raise_error
        Rockdove.logger.info "Reconnecting to the Exchange Server & Fetching the mail now."
        Rockdove::Follow::Ready.connect
        Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder) 
      rescue Viewpoint::EWS::EwsError
        send_connection_failed_message
      end

      def send_connection_failed_message
        Rockdove.logger.info "Rockdove unable to connect to the Exchange Server"
        return nil
      end
    end

    class PackUp
      def process(mail_retriever)
        item = mail_retriever.fetch_from_box
        to_folder = Rockdove::Follow::Ready.move_folder
        if to_folder.blank?
          item.delete!
          Rockdove.logger.info "Rockdove delivered the mail."
        else
          destination = Viewpoint::EWS::Folder.get_folder_by_name(to_folder)
          item.move!(destination)
          Rockdove.logger.info "Rockdove delivered & archived the mail."
        end
      end
    end
  end
end