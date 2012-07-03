module Rockdove
  class ExchangeMail
    extend Forwardable

    def_delegators :@mail_item, :to_recipients, :date_time_created, :date_time_sent, :from
    def_delegators :@mail_item, :subject, :body, :has_attachments?, :attachments
    
    def initialize(mail_item)
      @mail_item = mail_item
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
      parse_it(@mail_item.body, @mail_item.body_type) unless @mail_item.body.empty?
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
      Rockdove::DoveParser.new().parse_mail(mail_body, type) 
    end   
  end
end
