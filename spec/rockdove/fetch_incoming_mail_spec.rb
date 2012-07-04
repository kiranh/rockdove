require 'spec_helper.rb'

describe "FetchIncomingMail" do

  before(:each) do
    @connection = Rockdove::Follow::Ready
    @mail_retriever = Rockdove::Follow::CollectMail.new()
    @archive = Rockdove::Follow::ArchiveMail.new()
  end
  
  it "should validate the exchange server info provided" do
    @connection.url.should_not be_nil
    @connection.username.should_not be_nil
    @connection.password.should_not be_nil
    @connection.incoming_folder.should_not be_nil    
  end

  it "should connect to the Exchange Server" do
    @connection.should_receive(:connect).and_return(true)
    @connection.connect.should == true
  end

  it "should raise error for retrieval of inbox when there is no connection to exchange server" do
    @mail_retriever.inbox.should raise_error
  end

  it "is trying to fetch mail when there is no incoming mail" do
    @mail_retriever.should_receive(:inbox).and_return(nil)
    @mail_retriever.inbox.should == nil
  end

  it "is trying to fetch a new forwarded mail" do
    mail = fetch_mail("forwarded_mail")
    mail.should be_an_instance_of(Rockdove::EWS) 
    @mail_retriever.retrieve_mail(mail).should be_an_instance_of(Rockdove::ExchangeMail)
    @mail_retriever.retrieve_mail(mail).body.should == "FYI"  
    @mail_retriever.retrieve_mail(mail).subject.should == mail.subject 
    @mail_retriever.retrieve_mail(mail).attachments.should == mail.attachments
    @mail_retriever.retrieve_mail(mail).date_time_created.should == mail.date_time_created
    @mail_retriever.retrieve_mail(mail).date_time_sent.should == mail.date_time_sent
    convert_from_hash(mail)
    @mail_retriever.retrieve_mail(mail).from.should == "User.LastName@ewsdomain.com" 
  end

  it "is trying to fetch a new mail" do
    mail = fetch_mail("new_mail")  
    mail.should be_an_instance_of(Rockdove::EWS) 
    @mail_retriever.retrieve_mail(mail).should be_an_instance_of(Rockdove::ExchangeMail)   
    @mail_retriever.retrieve_mail(mail).body.should == "Hi, This is a new post"  
    @mail_retriever.retrieve_mail(mail).subject.should == mail.subject 
    @mail_retriever.retrieve_mail(mail).attachments.should == mail.attachments
    @mail_retriever.retrieve_mail(mail).date_time_created.should == mail.date_time_created
    @mail_retriever.retrieve_mail(mail).date_time_sent.should == mail.date_time_sent
    convert_from_hash(mail)
    @mail_retriever.retrieve_mail(mail).from.should == "User.LastName@ewsdomain.com"  
  end

  it "is trying to fetch a new replied mail" do
    mail = fetch_mail("replied_mail")
    mail.should be_an_instance_of(Rockdove::EWS) 
    @mail_retriever.retrieve_mail(mail).should be_an_instance_of(Rockdove::ExchangeMail)
    @mail_retriever.retrieve_mail(mail).body.should == "This is a replied post from outlook"
    @mail_retriever.retrieve_mail(mail).subject.should == mail.subject 
    @mail_retriever.retrieve_mail(mail).attachments.should == mail.attachments
    @mail_retriever.retrieve_mail(mail).date_time_created.should == mail.date_time_created
    @mail_retriever.retrieve_mail(mail).date_time_sent.should == mail.date_time_sent 
    convert_from_hash(mail)
    @mail_retriever.retrieve_mail(mail).from.should == "User.LastName@ewsdomain.com"   
  end

  it "should archive the mail if user assigns ews move folder" do
    mail = fetch_mail("new_mail") 
    @mail_retriever.retrieve_mail(mail).should be_an_instance_of(Rockdove::ExchangeMail)
    stub_destination_point
    @archive.process(@mail_retriever).should == true
  end

  it "should delete the mail if user doesn't assign ews move folder" do
    @connection.move_folder = nil
    mail = fetch_mail("new_mail") 
    @mail_retriever.retrieve_mail(mail).should be_an_instance_of(Rockdove::ExchangeMail)
    @archive.process(@mail_retriever).should == true
  end

  it "should parse the signature of the mail" do
    mail = fetch_mail("sample_mail") 
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
    @mail_retriever.should_receive(:retrieve_mail).at_most(:twice).and_return(mail)
    output = Rockdove::Follow::CollectMail.send_rockdove_to_watch_mail(@mail_retriever) do |mail|
     true
    end
    output.should == true
  end

  it "should collect all letters" do
    #puts Rockdove::Follow::CollectMail.new.group_of_mails.inspect
  end

  def stub_fetch_from_box(mail)
    @mail_retriever.should_receive(:fetch_from_box).at_most(8).times.and_return(mail)
  end

  def convert_from_hash(mail)
    from_object = convert_to_class(mail.from)
    mail.should_receive(:from).twice.and_return(from_object)
  end

  def stub_destination_point
    @archive.should_receive(:destination).and_return(true)
  end

  def fetch_mail(name)
    mail = get_mail(name)
    stub_fetch_from_box(mail) 
    mail
  end

  def convert_to_class(hash)
    Hash2Class.new(hash)
  end

end