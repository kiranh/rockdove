require 'spec_helper.rb'

describe "FetchIncomingMail" do

  before(:each) do
    Rockdove::Follow::Ready.stub!(:connect).and_return(:true)
    @mail_retriever = Rockdove::Follow::Action.new()
  end
  
  it "should validate the exchange server info provided" do
    Rockdove::Follow::Ready.url.should_not be_nil
    Rockdove::Follow::Ready.username.should_not be_nil
    Rockdove::Follow::Ready.password.should_not be_nil
    Rockdove::Follow::Ready.incoming_folder.should_not be_nil    
  end

  it "should connect to the Exchange Server" do
    Rockdove::Follow::Ready.connect.should == :true
  end

  it "is trying to fetch mail when there is no incoming mail" do
    @mail_retriever.should_receive(:inbox).and_return(nil)
    @mail_retriever.retrieve_mail() == nil
  end

  it "is trying to fetch a new forwarded mail" do
    mail = get_mail("forwarded_mail")
    @mail_retriever.should_receive(:fetch_from_box).and_return(mail)       
    @mail_retriever.retrieve_mail.should be_an_instance_of(Rockdove::ExchangeMail)
    @mail_retriever.should_receive(:fetch_from_box).and_return(mail)       
    @mail_retriever.retrieve_mail.body.should == "FYI"    
  end

  it "is trying to fetch a new mail" do
    mail = get_mail("new_mail")
    @mail_retriever.should_receive(:fetch_from_box).and_return(mail)       
    @mail_retriever.retrieve_mail.should be_an_instance_of(Rockdove::ExchangeMail)
    @mail_retriever.should_receive(:fetch_from_box).and_return(mail)       
    @mail_retriever.retrieve_mail.body.should == "Hi, This is a new post"    
  end

  #it "should connect to the Exchange Server" do
  #  puts Rockdove::Follow::Action.new().retrieve_mail.body.inspect
  #end

  def get_mail(name)
    YAML.load(email(name.to_sym))    
  end

  def email(name)
    IO.read EMAIL_FIXTURE_PATH.join("#{name}.yml").to_s
  end

end