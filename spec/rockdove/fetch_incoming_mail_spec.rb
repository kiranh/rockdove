require 'spec_helper.rb'

describe "FetchIncomingMail" do

  before(:each) do
    @connection = Rockdove::Config
    @mail_retriever = Rockdove::CollectMail.new()
    @log_stream = StringIO.new
    Rockdove.stub!(:logger).and_return(Logger.new(@log_stream))
    @test_server = Rockdove::EWS.new()
  end
  
  it "should validate the exchange server info provided" do
    @connection.url.should_not be_nil
    @connection.username.should_not be_nil
    @connection.password.should_not be_nil
    @connection.incoming_folder.should_not be_nil
  end

  it "should raise error for retrieval of inbox when there is no connection to exchange server" do
    @mail_retriever.inbox.should raise_error
  end

  it "is trying to fetch mail when there is no incoming mail" do
    @mail_retriever.should_receive(:inbox).and_return(nil)
    @mail_retriever.group_of_mails.should == nil
  end

  it "is trying to fetch a new forwarded mail" do
    mail = fetch_mail("forwarded_mail")
    mail.should be_an_instance_of(Rockdove::EWS)
    handle_inbox(Array(mail))
    result = @mail_retriever.retrieve_mail(mail)  
    result.should be_an_instance_of(Rockdove::ExchangeMail)
    result.body.should == "FYI"  
    match_results(result, mail)
    convert_from_hash(mail)
    result.from.should == "User.LastName@ewsdomain.com" 
    result.auto_response?.should == false
  end

  it "is trying to fetch a new mail" do
    mail = fetch_mail("new_mail")  
    mail.should be_an_instance_of(Rockdove::EWS)
    handle_inbox(Array(mail))
    result = @mail_retriever.retrieve_mail(mail) 
    result.should be_an_instance_of(Rockdove::ExchangeMail)   
    result.body.should == "Hi, This is a new post"  
    match_results(result, mail)
    convert_from_hash(mail)
    result.from.should == "User.LastName@ewsdomain.com"  
    result.auto_response?.should == false
  end

  it "is trying to fetch a new replied mail" do
    mail = fetch_mail("replied_mail")
    mail.should be_an_instance_of(Rockdove::EWS) 
    handle_inbox(Array(mail))
    result = @mail_retriever.retrieve_mail(mail)
    result.should be_an_instance_of(Rockdove::ExchangeMail)
    result.body.should == "This is a replied post from outlook"
    match_results(result, mail)
    convert_from_hash(mail)
    result.from.should == "User.LastName@ewsdomain.com"   
    result.auto_response?.should == false
  end

  def match_results(result, mail)
    result.subject.should == mail.subject 
    result.attachments.should == mail.attachments
    result.date_time_created.should == mail.date_time_created
    result.date_time_sent.should == mail.date_time_sent 
  end

  def handle_inbox(mail_array)
    @mail_retriever.should_receive(:inbox).at_most(:twice).and_return(@test_server)
    @test_server.should_receive(:find_items).at_most(:twice).and_return(mail_array)
    @test_server.should_receive(:get_items).at_most(:twice).and_return(mail_array)
    @mail_retriever.retrieve_mail(mail_array.first).should be_an_instance_of(Rockdove::ExchangeMail)
  end

end