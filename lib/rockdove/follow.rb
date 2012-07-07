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
        Viewpoint::EWS::EWS.instance
      end
    end

    class CollectMail
      UNDELIVERABLE = /Undeliverable/
      AUTO_REPLY = /Automatic reply/
      SPAM = /SPAM/

      class << self
        attr_accessor :mail_stack, :inbox_connection
      end

      def initialize(mail_stack = nil, inbox = nil)
        @mail_stack = mail_stack
        @inbox_connection = inbox
      end

      def self.watch &block
        loop do
          begin
            mail_retriever = Rockdove::Follow::CollectMail.new()
            send_rockdove_to_watch_mail(mail_retriever, &block)
          rescue Exception => e
            Rockdove.logger.error [e, *e.backtrace].join("\n")
          ensure
            sleep(Rockdove::Follow::Ready.watch_interval)
          end
        end
      end

      def self.send_rockdove_to_watch_mail(mail_retriever, &block)
        Rockdove.logger.info "Rockdove on watch for new mail..."
        parsed_mails = mail_retriever.group_of_mails
        if parsed_mails
          Rockdove.logger.info "Rockdove calling App block"
          block.call(parsed_mails)
          mail_retriever.process
        end
      end

      def group_of_mails
        return no_mail_alert unless fetch_from_box 
        Rockdove.logger.info "Rockdove collected #{fetch_from_box.count} mail(s)."
        letters = RockdoveCollection.new
        @inbox_connection = inbox unless @inbox_connection     
        @mail_stack.reverse.each do |item|
          unless match_and_ignore_bounce_types(item)
            letters << retrieve_mail(@inbox_connection.get_item(item.id)) 
          else
            @mail_stack.delete(item)
          end
        end
        letters
      end

      def match_and_ignore_bounce_types(item)
        case item.subject 
        when UNDELIVERABLE, AUTO_REPLY, SPAM
          Rockdove.logger.info "Rockdove deleted this mail: #{item.subject}."
          item.delete!
          true
        else  
          false
        end
      end

      def retrieve_mail(fetched_mail)               
        Rockdove::ExchangeMail.new(fetched_mail)
      end

      def no_mail_alert
        Rockdove.logger.info "Rockdove observed no mail yet."
        nil       
      end

      def fetch_from_box 
        @inbox_connection = inbox       
        return nil if @inbox_connection.nil? || @inbox_connection == true
        @mail_stack = @inbox_connection.find_items 
        return nil if @mail_stack.empty?
        @mail_stack    
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
        
      def process
        @to_folder = Rockdove::Follow::Ready.move_folder
        @mail_stack.each do |item|
          archive(item)
        end
        @mail_stack = nil
      end

      def archive(item)
        if @to_folder.blank?
          item.delete!
          Rockdove.logger.info "Rockdove delivered & deleted the mail."
        else
          item.move!(destination(@to_folder))
          Rockdove.logger.info "Rockdove delivered & archived the mail."
        end
      end
      
      def destination(to_folder)
        Viewpoint::EWS::Folder.get_folder_by_name(to_folder)
      end
    end
  end
end