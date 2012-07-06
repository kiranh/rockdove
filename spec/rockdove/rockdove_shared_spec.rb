# encoding: UTF-8

require 'spec_helper.rb'

module Rockdove
  class EWS
    attr_accessor :to_recipients, :date_time_created, :date_time_sent, :from
    attr_accessor :subject, :body, :body_type, :attachments, :id

    def find_items(value = nil)
      value
    end

    def self.id
      111111
    end

    def move!(destination)
      true
    end

    def delete!
      true
    end
  end
end

class Hash2Class
  def initialize(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
  end
end

def get_mail(name)
  YAML.load(fetch_mail_path(name.to_sym))    
end

def fetch_mail_path(name)
  IO.read EMAIL_FIXTURES.join("#{name}.yml").to_s
end