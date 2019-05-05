# frozen_string_literal: true

require 'webdrivers/logger'
require 'webdrivers/network'
require 'webdrivers/system'
require 'webdrivers/common'
require 'webdrivers/drivers/chromedriver'
require 'webdrivers/drivers/geckodriver'
require 'webdrivers/drivers/iedriver'
require 'webdrivers/drivers/mswebdriver'
require 'webdrivers/selenium'

module Webdrivers
  class ConnectionError < StandardError
  end

  class VersionError < StandardError
  end

  class << self
    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_pass, :install_dir
    attr_writer :cache_time

    def cache_time=(value)
      @cache_time = value
    end

    def cache_time
      @cache_time || 0
    end

    def logger
      @logger ||= Webdrivers::Logger.new
    end

    def configure
      yield self
    end

    def net_http_ssl_fix
      raise 'Webdrivers.net_http_ssl_fix is no longer available.' \
      ' Please see https://github.com/titusfortner/webdrivers#ssl_connect-errors.'
    end
  end
end
