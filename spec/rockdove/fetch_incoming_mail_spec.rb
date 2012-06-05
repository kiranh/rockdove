require 'spec_helper.rb'

describe "FetchIncomingMail" do
  it "should connect to the exchange web service url and authenticate" do
  	Rockdove::Ready.connect.should == true
  end

   it "should be able to retrieve the incoming mail" do
   	 Rockdove::Ready.retrieve_mail.should be_an_instance_of(Viewpoint::EWS::Message)  
   end

   #context "parse the mail" do
   #  before do 
   #	  	@mail = "<html>\r\n<head>\r\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\r\n</head>\r\n<body>\r\nTest reply to the common mailbox.\r\n<div><br clear=\"all\">\r\n<div>Thanks and Regards,</div>\r\n<div>Viswanath</div>\r\n<div><b><a href=\"https://csocial.cognizant.com/u/103771\" target=\"_blank\">https://csocial.cognizant.com/u/103771</a></b></div>\r\n<div><b><br>\r\n</b></div>\r\n<br>\r\n<br>\r\n<br>\r\n<div class=\"gmail_quote\">On Thu, May 10, 2012 at 8:19 AM, socialtango <span dir=\"ltr\">\r\n&lt;<a href=\"mailto:socialtango@cognizant.com\" target=\"_blank\">socialtango@cognizant.com</a>&gt;</span> wrote:<br>\r\n<blockquote class=\"gmail_quote\" style=\"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex\">\r\n<u></u>\r\n<div>\r\n<p><font>Test mail from new SocialTango mailbox<br>\r\n</font></p>\r\n</div>\r\n</blockquote>\r\n</div>\r\n<br>\r\n</div>\r\n</body>\r\n</html>\r\n"
   #	 end
   #  it "should be able to parse the mail item" do
   #    Rockdove::Ready.parse_mail(@mail).should == true
   #  end
   #end

end