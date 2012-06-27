require 'spec_helper.rb'

describe "FetchIncomingMail" do

  module Rockdove
    class EWS
      attr_accessor :to_recipients, :date_time_created, :date_time_sent, :from
      attr_accessor :subject, :body, :body_type, :attachments
    end
  end

  before(:each) do
    @mail_retriever = Rockdove::Follow::Action.new()
    @connection = Rockdove::Follow::Ready
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

  it "is trying to fetch mail when there is no incoming mail" do
    @mail_retriever.should_receive(:inbox).and_return(nil)
    @mail_retriever.retrieve_mail() == nil
  end

  it "is trying to fetch a new forwarded mail" do
    mail = get_mail("forwarded_mail")
    test_instance_of(mail)
    stub_fetch_from_box(mail)       
    @mail_retriever.retrieve_mail.body.should == "FYI"    
  end

  it "is trying to fetch a new mail" do
    mail = get_mail("new_mail")
    test_instance_of(mail)
    stub_fetch_from_box(mail)      
    @mail_retriever.retrieve_mail.body.should == "Hi, This is a new post"    
  end

  it "is trying to fetch a new replied mail" do
    mail = get_mail("replied_mail")
    test_instance_of(mail)
    stub_fetch_from_box(mail)     
    @mail_retriever.retrieve_mail.body.should == "This is a replied post from outlook"    
  end

  def test_instance_of(mail)
    stub_fetch_from_box(mail)     
    @mail_retriever.retrieve_mail.should be_an_instance_of(Rockdove::ExchangeMail)
  end

  def stub_fetch_from_box(mail)
    @mail_retriever.should_receive(:fetch_from_box).and_return(mail)
  end

  def get_mail(name)
    YAML.load(email(name.to_sym))    
  end

  def email(name)
    IO.read EMAIL_FIXTURE_PATH.join("#{name}.yml").to_s
  end

end