require 'spec_helper.rb'

module Rockdove
  class EWS
    attr_accessor :to_recipients, :date_time_created, :date_time_sent, :from
    attr_accessor :subject, :body, :body_type, :attachments

    def id
      rand(10)
    end

    def response(value)
      value
    end

    def find_items(value = nil)
      value
    end

    def get_item(item)
      item
    end

    def get_items(mail,key,shape)
      Array(mail)
    end

    def move!(destination)
      response("Archived the Mail Item")
    end

    def delete!
      response("Deleted the Mail Item")
    end

  end
end

class Hash2Class
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  
    end
  end
end

def convert_from_hash(mail)
  from_object = convert_to_class(mail.from)
  mail.should_receive(:from).at_most(3).times.and_return(from_object)
end

def convert_to_class(hash)
  Hash2Class.new(hash)
end

def fetch_mail(name)
  YAML.load(fetch_mail_path(name.to_sym))    
end

def fetch_mail_path(name)
  IO.read EMAIL_FIXTURES.join("#{name}.yml").to_s
end