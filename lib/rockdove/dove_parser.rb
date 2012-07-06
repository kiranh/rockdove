require 'email_reply_parser'
module Rockdove
  class DoveParser
    HTML_REGEXP = /<\/?[^>]*>/
    FWD_REGEXP = /^(On(.+)wrote:.+\z)$/nm
    SIGNATURE_REGEXP = /^(Thanks(.+)Regards.+\z)$/inm
    REPLY_REGEXP = /^(From:(.+)Sent:.+\z)$/nm
    DASHES = "________________________________________"

    def parse_mail(mail, body_type)
      Rockdove.logger.info "Rockdove is parsing the mail content now..."
      return nil unless mail
      mail.gsub!(HTML_REGEXP, "").strip! if body_type == "HTML"
      parsed_content = EmailReplyParser.parse_reply(mail) 
      choose_and_parse(parsed_content)
    end

    def choose_and_parse(content)
      content.gsub!(DASHES,"")      
      case content         
        when REPLY_REGEXP
          content.gsub(REPLY_REGEXP,"").strip!
        when FWD_REGEXP
          content.gsub(FWD_REGEXP,"").strip!
        else
          content
      end
      content.gsub(SIGNATURE_REGEXP,"").strip! if content =~ SIGNATURE_REGEXP          
    end   
  end
end