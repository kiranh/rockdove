module Rockdove
  class CollectMail
    UNDELIVERABLE = /Undeliverable/i
    AUTO_REPLY = /Automatic reply/i
    SPAM = /SPAM/i

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
          mail_retriever = new()
          mail_retriever.send_rockdove_to_watch_mail(&block)
        rescue Exception => e
          Rockdove.logger.error [e, *e.backtrace].join("\n")
        ensure
          sleep(Rockdove::Config.watch_interval)
        end
      end
    end

    def send_rockdove_to_watch_mail(&block)
      Rockdove.logger.info "Rockdove on watch for new mail..."
      parsed_mails = group_of_mails
      if parsed_mails
        Rockdove.logger.info "Rockdove calling App block"
        block.call(parsed_mails)
        process()
      end
    end

    def group_of_mails
      return no_mail_alert unless fetch_from_box
      Rockdove.logger.info "Rockdove collected #{fetch_from_box.count} mail(s)."
      letters = RockdoveCollection.new

      @mail_stack.reverse.each do |item|
        if spammy_mail?(item)
          @mail_stack.delete(item)
        else
          letters << retrieve_mail(@inbox_connection.get_item(item.id))
        end
      end
      letters
    end

    def spammy_mail?(item)
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
      Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder)
    rescue
      reconnect_and_raise_error
    end

    def reconnect_and_raise_error
      Rockdove.logger.info "Reconnecting to the Exchange Server & Fetching the mail now."
      Rockdove::Config.connect
      Viewpoint::EWS::Folder.get_folder_by_name(@incoming_folder)
    rescue Viewpoint::EWS::EwsError
      send_connection_failed_message
    end

    def send_connection_failed_message
      Rockdove.logger.info "Rockdove unable to connect to the Exchange Server"
      return nil
    end

    def process
      @to_folder = Rockdove::Config.archive_folder
      @mail_stack.each {|item| archive(item) }
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