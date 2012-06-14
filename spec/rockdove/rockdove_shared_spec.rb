require 'spec_helper.rb'
require 'pathname'

dir = Pathname.new File.expand_path(File.dirname(__FILE__))

EMAIL_FIXTURE_PATH = dir + 'emails'

shared_examples "a exchange mail" do
  describe "connect" do
    it "adds objects to the end of the collection" do
      collection << 1
      collection << 2
      collection.to_a.should eq([1,2])
    end
  end
end

def email(name)
  body = IO.read EMAIL_FIXTURE_PATH.join("#{name}.eml").to_s
  body
end