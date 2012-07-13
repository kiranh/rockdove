module Rockdove
  class EmailParser
    HTML_REGEXP = /<\/?[^>]*>/
    FWD_REGEXP = /^(On(.+)wrote:.+\z)$/inm
    SIGNATURE_REGEXP = /^(Thanks(.+)Regards.+\z)$/inm
    REPLY_REGEXP = /^(From:(.+)Sent:.+\z)$/inm    
    DASHES = "________________________________________"

    def self.parse_mail(mail, body_type)
      new().parse_email_tags(mail,body_type)
    end

    def parse_email_tags(mail,body_type)
      Rockdove.logger.info "Rockdove is parsing the mail content now..."
      return nil unless mail
      mail.gsub!(HTML_REGEXP, "").strip! if body_type == "HTML"
      parsed_content = EmailReplyParser.parse_reply(mail)
      choose_and_parse(parsed_content)      
    end

    def choose_and_parse(content)
      content.gsub!(DASHES,"")      
      case content       
      when SIGNATURE_REGEXP 
        content.gsub(SIGNATURE_REGEXP,"").strip! 
      when REPLY_REGEXP
        content.gsub(REPLY_REGEXP,"").strip!
      when FWD_REGEXP
        content.gsub(FWD_REGEXP,"").strip!
      else
        content
      end      
    end  

    # Strip the combined links with text and retrieve only text
    def self.strip_text_combined_links(content)
      words = content.split(" ")
      words.each do |w|
        case w
          when /^http/
            return
          when /http/
            words[words.index(w)] = w.split("http")[0]
        end
      end
    end

  end
end
