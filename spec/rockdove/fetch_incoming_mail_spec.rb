require 'spec_helper.rb'

describe "FetchIncomingMail" do
  it "should connect to the exchange web service url and authenticate" do
  	Rockdove::Ready.connect.should == true
  end

   it "should be able to retrieve the incoming mail" do
   	 Rockdove::Ready.retrieve_mail.should be_an_instance_of(Viewpoint::EWS::Folder)  
   end

end