require 'spec_helper.rb'
require 'pathname'

dir = Pathname.new File.expand_path(File.dirname(__FILE__))

EMAIL_FIXTURE_PATH = dir + 'emails'

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
    #mail_retriever.should_receive(:retrieve_mail).and_return(false)
    #mail_retriever.retrieve_mail().should == false
  end

  it "is trying to fetch a new mail" do
    mail = email(:sample_new_mail)
    @mail_retriever.stub(:fetch_from_box).and_return(mail)       
    @mail_retriever.fetch_from_box.should == mail

    puts @mail_retriever.retrieve_mail()
    #.should be_an_instance_of(ExchangeMail)
    #puts Rockdove::Follow::Action.new().retrieve_mail().inspect
  end

  def email(name)
    IO.read EMAIL_FIXTURE_PATH.join("#{name}.eml").to_s    
  end


   #context "parse the mail" do
   #  it "should be able to parse the mail item" do
   #    Rockdove::Ready.parse_mail(@mail).should == true
   #  end
   #end

end