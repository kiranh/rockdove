require 'spec_helper.rb'

describe "FetchIncomingMail" do

  before(:each) do
    @connection = Rockdove::Config
    @mail_retriever = Rockdove::CollectMail.new()
    @log_stream = StringIO.new
    Rockdove.stub!(:logger).and_return(Logger.new(@log_stream))
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
    result = @mail_retriever.retrieve_mail(mail)  
    result.should be_an_instance_of(Rockdove::ExchangeMail)
    result.body.should == "FYI"  
    match_results(result, mail)
    convert_from_hash(mail)
    result.from.should == "User.LastName@ewsdomain.com" 
  end

  it "is trying to fetch a new mail" do
    mail = fetch_mail("new_mail")  
    mail.should be_an_instance_of(Rockdove::EWS)
    result = @mail_retriever.retrieve_mail(mail) 
    result.should be_an_instance_of(Rockdove::ExchangeMail)   
    result.body.should == "Hi, This is a new post"  
    match_results(result, mail)
    convert_from_hash(mail)
    result.from.should == "User.LastName@ewsdomain.com"  
  end

  it "is trying to fetch a new replied mail" do
    mail = fetch_mail("replied_mail")
    mail.should be_an_instance_of(Rockdove::EWS) 
    result = @mail_retriever.retrieve_mail(mail)
    result.should be_an_instance_of(Rockdove::ExchangeMail)
    result.body.should == "This is a replied post from outlook"
    match_results(result, mail)
    convert_from_hash(mail)
    result.from.should == "User.LastName@ewsdomain.com"   
  end

  def match_results(result, mail)
    result.subject.should == mail.subject 
    result.attachments.should == mail.attachments
    result.date_time_created.should == mail.date_time_created
    result.date_time_sent.should == mail.date_time_sent 
  end

  def convert_from_hash(mail)
    from_object = convert_to_class(mail.from)
    mail.should_receive(:from).twice.and_return(from_object)
  end

  def convert_to_class(hash)
    Hash2Class.new(hash)
  end

end