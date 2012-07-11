module Rockdove

  class RockdoveCollection < Array
  end

  class ExchangeMail
    extend Forwardable

    def_delegators :@mail_item, :to_recipients, :date_time_created, :date_time_sent, :from, :body, :body_type
    def_delegators :@mail_item, :subject, :body, :has_attachments?, :attachments, :text_only=, :text_only? 

    attr_accessor :connection
    
    def initialize(mail_item, connection)
      @mail_item = mail_item
      @connection = connection
    end

    def to_recipients
      @mail_item.to_recipients.collect &:email_address if @mail_item.to_recipients
    end

    def cc_recipients
      @mail_item.cc_recipients.collect &:email_address if @mail_item.cc_recipients
    end

    def from
      @mail_item.from.email_address if @mail_item.from
    end

    def subject
      @mail_item.subject
    end

    def body
      mail = get_items(@mail_item)
      parse_it(mail.first.body, mail.first.body_type) unless mail.first.body.empty?
    end

    def get_items(mail)
      @connection.get_items([mail.id], nil, {:item_shape => retrieve_text_type})
    end

    def attachments
      @mail_item.attachments
    end

    def date_time_created
      @mail_item.date_time_created
    end

    def date_time_sent
      @mail_item.date_time_sent
    end

    def parse_it(mail_body, type)
      Rockdove::EmailParser.parse_mail(mail_body, type)
    end  

    def retrieve_text_type
      {:base_shape=>"AllProperties", :body_type=>"Text"}
    end 
  end
end
