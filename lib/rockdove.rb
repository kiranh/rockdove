require 'viewpoint'
require "rockdove/version"
require "rockdove/follow"
require "rockdove/dove_parser"
require "rockdove/dovetie" if defined?(Rails)

module Rockdove

  class << self
    attr_accessor :logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

end
