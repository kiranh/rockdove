module Rockdove
  # Rockdove Generators module	
  module Generators
  	# This generator copies the rockdove_server script file to your rails application script folder
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../rockdove/script", __FILE__)
            
      desc "This generator copies the rockdove_server script file to your rails project"
      # copy_script copies the rockdove_server script file to your application script folder
      def copy_script
        copy_file "rockdove_server.rb", "script/rockdove_server.rb"
      end
    end
  end
end