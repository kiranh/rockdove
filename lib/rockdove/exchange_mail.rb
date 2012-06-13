module Rockdove
  class ExchangeMail
    
    attr_accessor :from, :to, :cc, :subject, :body, :datetime_sent, :datetime_created
    attr_accessor :has_attachments, :attachments, :attachments_count
    
    #
    # initialize(incoming_email) takes in the parsed mail content and creates a Exchange mail object to be used or processed further in your code.
    # It returns all the mail info along with the attachments, if exists.
    #
    def initialize(incoming_email)      
      @from = incoming_email.from.email_address
      Rockdove.logger.info "Rockdove received the mail from #{@from}..."
      @to = incoming_email.to_recipients.collect &:email_address if incoming_email.to_recipients
      @cc = incoming_email.cc_recipients.collect &:email_address if incoming_email.cc_recipients
      @subject = incoming_email.subject.strip
      @body = Rockdove::DoveParser.new().parse_mail(incoming_email.body, incoming_email.body_type) if incoming_email.body.length > 0 
      @datetime_sent = incoming_email.date_time_sent
      @datetime_created = incoming_email.date_time_created
      @has_attachments = incoming_email.has_attachments?    
      get_attachment_list(incoming_email.attachments) if @has_attachments
    end

    #
    # get_attachment_list(mail_attachments) takes care of processing the multiple attachments and returning the file content and name for each attachment.
    #
    def get_attachment_list(mail_attachments)
      Rockdove.logger.info "Looks like there are some attachments to this mail... "
      count = 0
      @attachments = Hash.new
      mail_attachments.each do |file|
        var_name = "RockdoveFile#{count}".to_sym
        @attachments["#{var_name}"]  = Hash.new
        @attachments["#{var_name}"][:id] = file.id
        @attachments["#{var_name}"][:content] = file.content
        @attachments["#{var_name}"][:name] = file.file_name       
        count += 1
      end
      @attachments_count = count
    end
  end
end
