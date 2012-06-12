module Rockdove
	class ExchangeMail
		
		attr_accessor :from, :to, :cc, :subject, :body, :datetime_sent, :datetime_created
		attr_accessor :has_attachments, :attachments

		def initialize(incoming_email)			
      @from = @raw_item.from.email_address
      Rockdove.logger.info "Rockdove received the mail from #{@dove_mail[:from]}..."
      @to = @raw_item.to_recipients.collect &:email_address if @raw_item.to_recipients
      @dove_mail[:cc] = @raw_item.cc_recipients.collect &:email_address if @raw_item.cc_recipients
      @dove_mail[:subject] = @raw_item.subject.strip
      @dove_mail[:body] = Rockdove::DoveParser.parse_mail(@raw_item.body, @raw_item.body_type) if @raw_item.body.length > 0 
      @dove_mail[:datetime_sent] = @raw_item.date_time_sent
      @dove_mail[:datetime_created] = @raw_item.date_time_created
      @dove_mail[:has_attachments?] = @raw_item.has_attachments?    
      get_attachment_list if @dove_mail[:has_attachments?] 
		end

		def parse_attachments

		end
	end
end
