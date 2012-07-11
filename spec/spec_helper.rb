require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/bundle/'
  add_filter '/spec'
end

require 'rockdove'
require 'rockdove/rockdove_shared_spec.rb'
require 'pathname'

dir = Pathname.new File.expand_path(File.dirname(__FILE__))

EMAIL_FIXTURES = dir + 'rockdove' + 'emails'

Rockdove::Config.configure do |config|
  config.ews_url 'https://ewsdomain.com/ews/exchange.asmx'
  config.ews_username 'username'
  config.ews_password 'password'
  config.ews_folder 'Inbox'
  config.ews_archive_folder 'Archive'
  config.ews_watch_interval 60
  config.ews_ignore_mails ["postmaster@ewsdomain.com"]
end

RSpec.configure do |c|
end

