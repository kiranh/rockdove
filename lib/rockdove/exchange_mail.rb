module Rockdove
  class ExchangeMail
    extend Forwardable

    def_delegators :@mail_item, :to_recipients, :date_time_created, :date_time_sent, :from, :to, :cc
    def_delegators :@mail_item, :subject, :body, :has_attachments?, :attachments
    
    def initialize(mail_item)
      @mail_item = mail_item
    end

    def to_recipients
      @mail_item.to_recipients.collect &:email_address
    end

    def cc_recipients
      @mail_item.cc_recipients.collect &:email_address  
    end

    def body
      parse_it(@mail_item.body, @mail_item.body_type)
    end

    def parse_it(mail_body, type)
      Rockdove::DoveParser.new().parse_mail(mail_body, type) unless mail_body.empty?
    end   
  end
end
