require 'spec_helper.rb'

class Hash2ClassObject
  def initialize(hash)
    hash.each do |k,v|     
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
  end
end

describe "FetchIncomingMail" do

  before(:each) do
    #Rockdove::Follow::Ready.stub!(:connect).and_return(:true)
    #@mail_retriever = Rockdove::Follow::Action.new()
  end
  
  it "should validate the exchange server info provided" do
    Rockdove::Follow::Ready.url.should_not be_nil
    Rockdove::Follow::Ready.username.should_not be_nil
    Rockdove::Follow::Ready.password.should_not be_nil
    Rockdove::Follow::Ready.incoming_folder.should_not be_nil    
  end

  it "should connect to the Exchange Server" do
    #Rockdove::Follow::Ready.connect.should == :true
  end

  it "is trying to fetch mail when there is no incoming mail" do
    #mail_retriever.should_receive(:retrieve_mail).and_return(false)
    #mail_retriever.retrieve_mail().should == false
  end

  it "is trying to fetch a new mail" do
    #mail = get_mail("sample_new_mail")
    #@mail_retriever.should_receive(:fetch_from_box).and_return(mail)       
    #@mail_retriever.fetch_from_box.should == mail
    #@mail_retriever.retrieve_mail.should be_an_instance_of(Rockdove::ExchangeMail)     
    puts Rockdove::Follow::Action.new().retrieve_mail().inspect
  end

  def get_mail(name)
    mail = Hash2ClassObject.new(YAML.load(email(name.to_sym)))
    mail.from = Hash2ClassObject.new(mail.from)
    mail
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