#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'logger'

CONFIG_FILE = ENV['HOME'] + "/.ipnotifierconfig"

class IPNotifier
  def initialize
    @logger = Logger.new(STDERR)
    @logger.level = Logger::DEBUG

    load_config
  end

  def load_config
    # load config file
    # config stores:
    #   previous IP
    #   email to send notification to
    #   email to send notification from
    # TODO handle when file does not exist
    config_text = File.read CONFIG_FILE
    config = JSON.parse config_text
    @logger.debug JSON.pretty_generate config

    @previous_ip = config["previous_ip"]
    @destination_email_address = config["destination_ip_address"]
    @source_email_address = config["source_email_address"]
  end

  def check_external_ip
    # TODO how to poll external IP address?
    # TODO error handling when no LAN/no WAN
    remote_ip = open('http://whatismyip.akamai.com').read
  end

  def send_email_notification
    #TODO
  end

  def update
    new_ip = check_external_ip
    @logger.info "Previous IP: #{@previous_ip}"
    @logger.info "Current IP:  #{new_ip}"

    if new_ip != @previous_ip
      #send_email_notification
      @previous_ip = new_ip
      write_config
    end  
  end

  def write_config
    config["previous_ip"] = @previous_ip
    config["destination_ip_address"] = @destination_email_address
    config["source_email_address"] = @source_email_address

    File.open(CONFIG_FILE, 'w') { |file|
      file.write(config.to_json)
    }
  end

end

# TODO provide interface for providing email addresses

if __FILE__==$0
  ipn = IPNotifier.new
  ipn.update
end
