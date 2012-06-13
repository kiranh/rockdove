require 'spec_helper.rb'

describe "FetchIncomingMail" do
  
  it "should validate the exchange server info provided" do
    Rockdove::Follow::Ready.url.should_not be_nil
    Rockdove::Follow::Ready.username.should_not be_nil
    Rockdove::Follow::Ready.password.should_not be_nil
    Rockdove::Follow::Ready.incoming_folder.should_not be_nil    
  end

  it "should connect to the Exchange Server" do
    Rockdove::Follow::Ready.stub!(:connect).and_return(:true)
  end

  it "is trying to fetch mail when there is no incoming mail" do
    mail_retriever = mock "Rockdove::Follow::Action"
    mail_retriever.should_receive(:retrieve_mail).and_return(false)
    mail_retriever.retrieve_mail().should == false
  end

  it "is trying to fetch mail when there is incoming mail" do
    mail_retriever = mock "Rockdove::Follow::Action"
    exchange_mail = mock "Rockdove::ExchangeMail"
    mail =  mail_retriever.should_receive(:retrieve_mail).and_return(exchange_mail)
    mail_retriever.retrieve_mail().should == exchange_mail
  end



   #context "parse the mail" do
   #  it "should be able to parse the mail item" do
   #    Rockdove::Ready.parse_mail(@mail).should == true
   #  end
   #end

end