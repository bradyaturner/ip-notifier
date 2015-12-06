#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'logger'
require 'net/smtp'

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
    @logger.debug "Config:\n#{JSON.pretty_generate config}"

    @previous_ip = config["previous_ip"]
    @destination_email_address = config["destination_email_address"]
    @source_email_address = config["source_email_address"]
    @outgoing_mail_domain = config["outgoing_mail_domain"]
    @mail_username = config["mail_username"]
    @mail_password = config["mail_password"]
  end

  def check_external_ip
    # TODO error handling when no LAN/no WAN
    remote_ip = open('http://whatismyip.akamai.com').read
  end

  def send_email_notification
    message = <<MESSAGE_END
    From: Private Person <#{@source_email_address}>
    To: A Test User <#{@destination_email_address}>
    Subject: #{@new_ip} is your new IP address.

    Your new IP address is #{@new_ip}. It was previously #{@previous_ip}.
MESSAGE_END

    @logger.info "Sending message:\n#{message}"

    smtp = Net::SMTP.new @outgoing_mail_domain, 587
    smtp.enable_starttls
    smtp.start('gmail.com', @mail_username, @mail_password, :login) do |smtp|
      smtp.send_message message, @source_email_address,
                                @destination_email_address
    end
  end

  def update
    @new_ip = check_external_ip
    @logger.info "Previous IP: #{@previous_ip}"
    @logger.info "Current IP:  #{@new_ip}"

    if @new_ip != @previous_ip
      send_email_notification
      @previous_ip = @new_ip
      write_config
    else
      @logger.info "No change."
    end  
  end

  def write_config
    config = {}
    config["previous_ip"] = @previous_ip
    config["destination_email_address"] = @destination_email_address
    config["source_email_address"] = @source_email_address
    config["outgoing_mail_domain"] = @outgoing_mail_domain
    config["mail_username"] = @mail_username
    config["mail_password"] = @mail_password

    File.open(CONFIG_FILE, 'w') { |file|
      file.write(JSON.pretty_generate config)
    }
  end

end

# TODO provide interface for providing email addresses

if __FILE__==$0
  ipn = IPNotifier.new
  ipn.update
end
