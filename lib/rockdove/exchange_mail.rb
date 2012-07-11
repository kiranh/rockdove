module Rockdove

  class RockdoveCollection < Array
  end

  class ExchangeMail
    extend Forwardable

    # The below specifics can be accessed via Rockdove::ExchangeMail @class_instance.
    def_delegators :@mail_item, :to_recipients, :date_time_created, :date_time_sent, :from, :body, :body_type
    def_delegators :@mail_item, :subject, :body, :has_attachments?, :attachments, :text_only=, :text_only? 

    attr_accessor :connection
    
    def initialize(mail_item, connection)
      @mail_item = mail_item
      @connection = connection
    end
    
    # Get a list of to recipients by accessing Rockdove::ExchangeMail @class_instance.to_recipients
    def to_recipients
      @mail_item.to_recipients.collect &:email_address if @mail_item.to_recipients
    end

    # Get a list of cc recipients by accessing Rockdove::ExchangeMail @class_instance.cc_recipients
    def cc_recipients
      @mail_item.cc_recipients.collect &:email_address if @mail_item.cc_recipients
    end

    # Retrieve from email address by accessing Rockdove::ExchangeMail @class_instance.from
    def from
      @mail_item.from.email_address if @mail_item.from
    end
    
    # Retrieve subject of the mail by accessing Rockdove::ExchangeMail @class_instance.subject
    def subject
      @mail_item.subject
    end

    # Retrieve parsed body content of the mail by accessing Rockdove::ExchangeMail @class_instance.body
    def body
      content = ""
      mail = get_items(@mail_item)
      content = parse_it(mail.first.body, mail.first.body_type) unless mail.first.body.empty?
      content.force_encoding('UTF-8') 
    end

    # Retrieves the mail item with text type body content
    def get_items(mail)
      @connection.get_items([mail.id], nil, {:item_shape => retrieve_text_type})
    end

    # Retrieve collection of attachments by accessing Rockdove::ExchangeMail @class_instance.attachments
    def attachments
      @mail_item.attachments
    end

    # Retrieve date_time_created of the mail by accessing Rockdove::ExchangeMail @class_instance.date_time_created
    def date_time_created
      @mail_item.date_time_created
    end

    # Retrieve date_time_sent of the mail by accessing Rockdove::ExchangeMail @class_instance.date_time_sent
    def date_time_sent
      @mail_item.date_time_sent
    end

    # This method parses the mail content provided @params of body and body_type
    def parse_it(mail_body, type)
      Rockdove::EmailParser.parse_mail(mail_body, type)
    end  

    # Retrieves text type body content of the mail
    def retrieve_text_type
      {:base_shape=>"AllProperties", :body_type=>"Text"}
    end 
  end
end
