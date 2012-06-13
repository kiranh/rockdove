require 'viewpoint'
require "rockdove/version"
require "rockdove/follow"
require "rockdove/dove_parser"
require "rockdove/dovetie" if defined?(Rails)

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
