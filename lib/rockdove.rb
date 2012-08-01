require 'viewpoint'
require 'email_reply_parser'
require "rockdove/version"
require "rockdove/config"
require "rockdove/exchange_mail"
require "rockdove/email_parser"
require "rockdove/collect_mail"
require "rockdove/dovetie" if defined?(Rails)

# The main Rockdove module	
module Rockdove

  class << self
    attr_accessor :logger
  end

  #
  # Enabling the logger for Rockdove to track its where-abouts during the delivery process of the mail.
  #

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

end

# Make String encodings work the same across 1.8 and 1.9 
class String
  # Make String force_encodings work the same across 1.8 and 1.9 
  def force_encoding(enc)
    self
  end
end