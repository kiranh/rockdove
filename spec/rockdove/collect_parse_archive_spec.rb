require 'spec_helper.rb'

describe "CollectParseArchive" do

  before(:each) do
    @connection = Rockdove::Follow::Ready
    @mail_retriever = Rockdove::Follow::CollectMail.new()
    @test_server = Rockdove::EWS.new()
    @log_stream = StringIO.new
    Rockdove.stub!(:logger).and_return(Logger.new(@log_stream))
  end

  it "is trying to fetch a group of mails at one polling cycle" do
    mails = []
    mails << fetch_mail("new_mail") << fetch_mail("forwarded_mail") << fetch_mail("replied_mail")
    handle_inbox(mails)
    result = @mail_retriever.group_of_mails
    result.should be_an_instance_of(Rockdove::RockdoveCollection)
    result.count.should == 3
    @log_stream.string.should include("Rockdove collected 3 mail(s)")
  end

  it "should archive the mail at the end of collection cycle if user assigns ews move folder" do
    mail = fetch_mail("new_mail") 
    handle_inbox(Array(mail))
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    stub_destination_point 
    lambda { @mail_retriever.process }.should_not raise_error
    @log_stream.string.should =~ /Rockdove delivered & archived the mail/
  end

  it "should delete the mail at the end of collection cycle if user doesn't assign ews move folder" do
    @connection.move_folder = nil
    mail = fetch_mail("new_mail") 
    handle_inbox(Array(mail))
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    lambda { @mail_retriever.process }.should_not raise_error
    @log_stream.string.should =~ /Rockdove delivered & deleted the mail/
  end

  it "should parse the signature of the mail" do
    mail = fetch_mail("mail_type_text") 
    parsed_content = Rockdove::DoveParser.new.parse_mail(mail.body, mail.body_type)
    parsed_content.should == "This is a new post"
  end 

  it "should parse the forwarded mail of gmail" do
    mail = fetch_mail("gmail_fwd_mail") 
    parsed_content = Rockdove::DoveParser.new.parse_mail(mail.body, mail.body_type)
    parsed_content.should == "I get proper rendering as well."
  end 

  it "should watch for new mail when called" do
    mail = fetch_mail("new_mail") 
    handle_inbox(Array(mail))
    output = Rockdove::Follow::CollectMail.send_rockdove_to_watch_mail(@mail_retriever) do |mail|
     true
    end
    @log_stream.string.should include("Rockdove calling App block")
    @log_stream.string.should include("Rockdove collected 1 mail(s)")
  end

  it "should handle undeliverable bounce type" do
    mail = fetch_mail("auto_reply_mail")
    handle_inbox(Array(mail))
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    @log_stream.string.should include("Rockdove deleted this mail: Automatic reply: Out of Office Message")
  end

  it "should handle auto reply bounce type" do
    mail = fetch_mail("undeliverable_mail")
    handle_inbox(Array(mail))
    @mail_retriever.group_of_mails.should be_an_instance_of(Rockdove::RockdoveCollection)
    @log_stream.string.should include("Rockdove deleted this mail: Undeliverable: New Post")
  end

  def handle_inbox(mail_array)
    @mail_retriever.should_receive(:inbox).at_most(:twice).and_return(@test_server)
    @test_server.should_receive(:find_items).at_most(:twice).and_return(mail_array)
    @mail_retriever.retrieve_mail(mail_array.first).should be_an_instance_of(Rockdove::ExchangeMail)
  end

  def stub_destination_point
    @mail_retriever.should_receive(:destination).and_return(@connection.move_folder)
  end
end

describe "RockdoveLogs" do
  it "should log" do
    Rockdove.logger.should be_an_instance_of(Logger)
  end
end