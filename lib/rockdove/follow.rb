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
      	@move_folder = value || 'Archive'
    	end

    	def self.ews_watch_interval( value )
      	@watch_interval = value || 60
    	end

    	def self.connect
    		Rockdove.logger.info "Hang On ! Rockdove is connecting to Exchange Server..."
      	Viewpoint::EWS::EWS.endpoint = @url
      	Viewpoint::EWS::EWS.set_auth @username, @password
    	end      
  	end

  	class Action 
    	class << self
      	attr_accessor :dove_mail, :raw_item
    	end

    	def self.retrieve_mail
    		inbox = fetch_box
      	all_mails  = inbox.find_items
      	if(all_mails.length > 0)
	        @raw_item = inbox.get_item(all_mails.first.id)
  	      collect_stuff if @raw_item
    	  end    	  
      	return @dove_mail
    	end

    	def self.collect_stuff
    		@dove_mail = Hash.new
      	@dove_mail[:from] = @raw_item.from.email_address
      	Rockdove.logger.info "Rockdove received the mail from #{@dove_mail[:from]}..."
      	@dove_mail[:to] = @raw_item.to_recipients.collect &:email_address if @raw_item.to_recipients
      	@dove_mail[:cc] = @raw_item.cc_recipients.collect &:email_address if @raw_item.cc_recipients
      	@dove_mail[:subject] = @raw_item.subject.strip
      	@dove_mail[:body] = Rockdove::DoveParser.parse_mail(@raw_item.body, @raw_item.body_type) if @raw_item.body.length > 0 
      	@dove_mail[:datetime_sent] = @raw_item.date_time_sent
      	@dove_mail[:datetime_created] = @raw_item.date_time_created
      	@dove_mail[:has_attachments?] = @raw_item.has_attachments?    
      	get_attachment_list if @dove_mail[:has_attachments?] 
    	end

    	def self.fetch_box
	      incoming_folder = Rockdove::Follow::Ready.incoming_folder
      	begin
	        return Viewpoint::EWS::Folder.get_folder_by_name(incoming_folder)
  	    rescue
  	    	Rockdove.logger.info "Reconnecting to the Exchange Server & Fetching the Mail now..."
    	    Rockdove::Ready.connect
      	  return Viewpoint::EWS::Folder.get_folder_by_name(incoming_folder)
      	end
    	end

    	def self.get_attachment_list
    		Rockdove.logger.info "Looks like there are some attachments to this mail... "
	    	count = 0
    		@dove_mail[:attachments] = Hash.new
    		@raw_item.attachments.each do |file|
	    		var_name = "File#{count}".to_sym
    			@dove_mail[:attachments]["#{var_name}"]  = Hash.new
    			@dove_mail[:attachments]["#{var_name}"][:id] = file.id
    			@dove_mail[:attachments]["#{var_name}"][:content] = file.content
    			@dove_mail[:attachments]["#{var_name}"][:name] = file.file_name    		
    			count += 1
    		end
    		@dove_mail[:attachments_count] = count
    	end

    	#Rockdove::Follow::Action.watch do |parsed_message|
    	#  Post.process_this_mail(parsed_message)
    	#end

    	def watch
	      loop do
        	begin
        		Rockdove.logger.info "Rockdove on watch for new mail ... "
          	parsed_message = Rockdove::Follow::Action.retrieve_mail
          	if parsed_message.values.any?
	            yield(parsed_message) 
            	Rockdove::Follow::PackUp.process
          	end
        	rescue Exception => e
	          Rockdove.logger.info(e)
        	ensure
	          sleep(Rockdove.watch_interval)
        	end
      	end
    	end

	  end

 	  class PackUp
   	  def process
    	  item = Rockdove::Follow::Action.raw_item
  	 	  to_folder = Rockdove::Follow::Ready.move_folder
    	  if to_folder.blank?
    	    item.delete!
    	    Rockdove.logger.info "Rockdove delivered the Mail..."
    	  else
   	      item.move!(to_folder)  
   	      Rockdove.logger.info "Rockdove delivered & archived the Mail..."
    	  end
    	end
  	end
	end
end