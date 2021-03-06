# frozen_string_literal: true

require 'webdrivers/common'

module Webdrivers
  class MSWebdriver < Common
    class << self
      def windows_version
        Webdrivers.logger.debug 'Checking current version'

        # current_version() from other webdrivers returns the version from the webdriver EXE.
        # Unfortunately, MicrosoftWebDriver.exe does not have an option to get the version.
        # To work around it we query the currently installed version of Microsoft Edge instead
        # and compare it to the list of available downloads.
        version = `powershell (Get-AppxPackage -Name Microsoft.MicrosoftEdge).Version`
        raise 'Failed to check Microsoft Edge version.' if version.empty? # Package name changed?

        Webdrivers.logger.debug "Current version of Microsoft Edge is #{version.chomp!}"

        build = version.split('.')[1] # "41.16299.248.0" => "16299"
        Webdrivers.logger.debug "Expecting MicrosoftWebDriver.exe version #{build}"
        build.to_i
      end

      # Webdriver binaries for Microsoft Edge are not backwards compatible.
      # For this reason, instead of downloading the latest binary we download the correct one for the
      # currently installed browser version.
      alias version windows_version

      def version=(*)
        raise 'Version can not be set for MSWebdriver because it is dependent on the version of Edge'
      end

      private

      def file_name
        'MicrosoftWebDriver.exe'
      end

      def downloads
        array = Nokogiri::HTML(get(base_url)).xpath("//li[@class='driver-download']/a")
        array.each_with_object({}) do |link, hash|
          next if link.text == 'Insiders'

          key = normalize_version link.text.scan(/\d+/).first.to_i
          hash[key] = link['href']
        end
      end

      def base_url
        'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/'
      end

      # Assume we have the latest if file exists since MicrosoftWebdriver.exe does not have an
      # argument to check the current version.
      def correct_binary?
        File.exist?(binary)
      end
    end
  end
end

if ::Selenium::WebDriver::Service.respond_to? :driver_path=
  ::Selenium::WebDriver::Edge::Service.driver_path = proc { ::Webdrivers::MSWebdriver.update }
else
  # v3.141.0 and lower
  module Selenium
    module WebDriver
      module Edge
        def self.driver_path
          @driver_path ||= Webdrivers::MSWebdriver.update
        end
      end
    end
  end
end
