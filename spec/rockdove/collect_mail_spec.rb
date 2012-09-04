require 'spec_helper.rb'

describe "CollectParseArchive" do

  before(:each) do
    @connection = Rockdove::Config
    @mail_retriever = Rockdove::CollectMail.new()
    @test_server = Rockdove::EWS.new()
    @log_stream = StringIO.new
    Rockdove.stub!(:logger).and_return(Logger.new(@log_stream))
  end

  it "is trying to fetch a group of mails at one polling cycle" do
    mails = []
    mails << fetch_mail("new_mail") << fetch_mail("forwarded_mail") << fetch_mail("replied_mail")
    handle_inbox(mails)
    mails.map {|mail| from_object = convert_to_class(mail.from) ; mail.should_receive(:from).at_most(3).times.and_return(from_object) }
    result = @mail_retriever.group_of_mails
    result.should be_an_instance_of(Rockdove::RockdoveCollection)
    result.count.should == 3
    @log_stream.string.should include("Rockdove collected 3 mail(s)")
  end

  it "should archive the mail at the end of collection cycle if user assigns ews move folder" do
    mail = fetch_mail("new_mail") 
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    stub_destination_point 
    lambda { @mail_retriever.process }.should_not raise_error
    @log_stream.string.should =~ /Rockdove delivered & archived the mail/
  end

  it "should delete the mail at the end of collection cycle if user doesn't assign ews move folder" do
    @connection.archive_folder = nil
    mail = fetch_mail("new_mail") 
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    lambda { @mail_retriever.process }.should_not raise_error
    @log_stream.string.should =~ /Rockdove delivered & deleted the mail/
  end

  it "should parse the signature of the mail" do
    mail = fetch_mail("mail_type_text") 
    convert_from_hash(mail)
    parsed_content = Rockdove::EmailParser.parse_mail(mail.body, mail.body_type)
    parsed_content.should == "This is a new post"
  end 

  it "should parse the forwarded mail of gmail" do
    mail = fetch_mail("gmail_fwd_mail") 
    parsed_content = Rockdove::EmailParser.parse_mail(mail.body, mail.body_type)
    parsed_content.should == "I get proper rendering as well."
  end 

  it "should watch for new mail when called" do
    mail = fetch_mail("new_mail") 
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    output = @mail_retriever.send_rockdove_to_watch_mail do |mail|
     true
    end
    @log_stream.string.should include("Rockdove calling App block")
    @log_stream.string.should include("Rockdove collected 1 mail(s)")
  end

  it "should handle undeliverable bounce type" do
    mail = fetch_mail("auto_reply_mail")
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    @mail_retriever.bounce_type_mail?(mail).should == true
    @log_stream.string.should include("Rockdove deleting this mail: Automatic reply: Out of Office Message")    
  end

  it "should ignore mails when specified under ews_ignore_mails list" do
    mail = fetch_mail("undeliverable_mail")
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    @log_stream.string.should include("Rockdove detected postmaster@ewsdomain.com under ignore mail list.")
  end

  it "should handle auto reply bounce type" do
    @connection.ews_ignore_mails([])
    mail = fetch_mail("undeliverable_mail")
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    @mail_retriever.bounce_type_mail?(mail).should == true
    @log_stream.string.should include("Rockdove deleting this mail: Undeliverable: New Post")
  end

  it "should be able to collect the attachment of a mail" do
    mail = fetch_mail("mail_with_attachment")
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    result = @mail_retriever.group_of_mails.first
    result.should be_an_instance_of(Rockdove::ExchangeMail)
    result.has_attachments? == true  
    load_attachment(result)
    result.attachments.first.file_name = "CI.png"
  end

  it "should be able to collect and save the attachment to a file" do
    mail = fetch_mail("mail_with_attachment")
    handle_inbox(Array(mail))
    convert_from_hash(mail)
    result = @mail_retriever.group_of_mails.first
    result.should be_an_instance_of(Rockdove::ExchangeMail)
    result.has_attachments? == true  
    load_attachment(result)
    attachment = result.attachments.first
    attachment.file_name.should == "CI.png"
    result.save_to_file(attachment, nil, "sample_file_name").should == true
  end

  def handle_inbox(mail_array)
    @mail_retriever.should_receive(:inbox).at_most(:twice).and_return(@test_server)
    @test_server.should_receive(:find_items).at_most(:twice).and_return(mail_array)
    @mail_retriever.retrieve_mail(mail_array.first).should be_an_instance_of(Rockdove::ExchangeMail)
  end

  def load_attachment(obj)
    attachment = fetch_mail("attachment")
    obj.should_receive(:attachments).at_most(:twice).and_return(Array(attachment))
  end

  def stub_destination_point
    @mail_retriever.should_receive(:destination).and_return(@connection.archive_folder)
  end
end

describe "RockdoveLogs" do
  it "should log" do
    Rockdove.logger.should be_an_instance_of(Logger)
  end
end