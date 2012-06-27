require 'rockdove'
require 'rails'
require 'pathname'

dir = Pathname.new File.expand_path(File.dirname(__FILE__))

GENERATOR_PATH = dir + '../generators/rockdove' 

module Rockdove
  class Dovetie < Rails::Railtie
    #initializer "dovetie.configure_rails_initialization" do |app|
    #  app.middleware.use Dovetie::Middleware
    #end
    generators do
      require "#{GENERATOR_PATH}/install_generator.rb"
    end
  end
end