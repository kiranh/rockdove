require 'spec_helper.rb'

describe "FetchIncomingMail" do
  
  it "should validate the exchange server info provided" do
    Rockdove::Follow::Ready.url.should_not be_nil
    Rockdove::Follow::Ready.username.should_not be_nil
    Rockdove::Follow::Ready.password.should_not be_nil
    Rockdove::Follow::Ready.incoming_folder.should_not be_nil    
  end

  it "should connect to the exchange web service url and authenticate" do
    Rockdove::Follow::Ready.connect.should == true
  end

  it "should be able to retrieve the incoming mail" do
    #puts Rockdove::Follow::Action.retrieve_mail  
    Rockdove::Follow::Action.retrieve_mail.should be_an_instance_of(Hash)  
  end

   #context "parse the mail" do
   #  it "should be able to parse the mail item" do
   #    Rockdove::Ready.parse_mail(@mail).should == true
   #  end
   #end

end