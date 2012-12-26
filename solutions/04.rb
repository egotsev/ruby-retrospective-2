module Patterns
  PHONE_CODE = /((\b00|\+)[1-9]\d{0,2}|\b0)/
  PHONE      = /#{PHONE_CODE}([- \(\)]{,2}[1-9])([- \(\)]{,2}[0-9]){6,10}/
  TLD        = /[a-zA-Z]{2,3}(\.[a-zA-Z]{2})?/
  HOSTNAME   = /([0-9a-zA-Z]([0-9a-zA-Z-]{,61}[0-9a-zA-Z])?\.)+#{TLD}/
  EMAIL      = /([a-zA-Z0-9])[\w\+\.-]{,200}@#{HOSTNAME}/
  IP_ADRESS  = /([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.\g<1>){3}/
  TIME       = /(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]/
  DATE       = /\d{4}-(0[1-9]|1[012])-(0[1-9]|[1-2][0-9]|3[01])/
  DATE_TIME  = /#{DATE}( |T)#{TIME}/
  INTEGER    = /-?(0|[1-9][0-9]*)/
  NUMBER     = /-?(0|[1-9][0-9]*)(\.[0-9]+)?/
end

class PrivacyFilter
  include Patterns

  attr_accessor :preserve_phone_country_code
  attr_accessor :preserve_email_hostname
  attr_accessor :partially_preserve_email_username

  def initialize(text)
    @text = text
    @email_regexp = /\b#{EMAIL}\b/
    @phone_regexp = /#{PHONE}\b/
  end

  def filtered
    result = filter_emails @text
    result = filter_phone_numbers result
  end

  private

  def filter_emails(text)
    text.gsub(@email_regexp) do |match|
      if !preserve_email_hostname and !partially_preserve_email_username
        '[EMAIL]'
      else
        preserve_email_components match
      end
    end
  end

  def filter_phone_numbers(text)
    text.gsub(@phone_regexp) do |match|
      if !preserve_phone_country_code
        "[PHONE]"
      else
        preserve_phone_components $1, match
      end
    end
  end

  def preserve_email_components(text)
    username, hostname = text.split('@')
    return "[FILTERED]@#{hostname}" if username.size < 6
    return "#{username[0,3]}[FILTERED]@#{hostname}" if partially_preserve_email_username
    return "[FILTERED]@#{hostname}" if preserve_email_hostname
  end

  def preserve_phone_components(prefix, phone)
    if prefix == '0'
      "[PHONE]"
    else
      "#{prefix} [FILTERED]"
    end
  end
end

class Validations
  include Patterns

  def self.email?(value)
    /\A#{EMAIL}\z/ === value
  end

  def self.phone?(value)
    /\A#{PHONE}\z/ === value
  end

  def self.hostname?(value)
    /\A#{HOSTNAME}\z/ === value
  end

  def self.ip_address?(value)
    /\A#{IP_ADRESS}\z/ === value
  end

  def self.number?(value)
    /\A#{NUMBER}\z/ === value
  end

  def self.integer?(value)
    /\A#{INTEGER}\z/ === value
  end

  def self.date?(value)
    /\A#{DATE}\z/ === value
  end

  def self.time?(value)
    /\A#{TIME}\z/ === value
  end

  def self.date_time?(value)
    /\A#{DATE_TIME}\z/ === value
  end
end
