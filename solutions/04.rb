class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially_preserve_email_username
  def initialize(text)
    @text = text
    @email_regexp = /\b(([a-zA-Z0-9])[\w\+\.-]{,200})@((\g<2>((\g<2>|-){,61}\g<2>)?\.)+[a-zA-Z]{2,3}(\.[a-zA-Z]{2})?)\b/
    @phone_regexp = /((\b00|\+)[1-9]\d{0,2}|\b0)([- \(\)]{,2}\d)\g<3>{5,10}\b/
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
  def self.email?(value)
    case value
      when /\A([a-zA-Z0-9])[\w\+\.-]{,200}@(\g<1>([0-9a-zA-Z-]{,61}\g<1>)?\.)+[a-zA-Z]{2,3}(\.[a-zA-Z]{2})?\z/
        true
      else
        false
    end
  end

  def self.phone?(value)
    /\A((00|\+)[1-9]\d{0,2}|0)([- \(\)]{,2}\d)\g<3>{5,10}\z/ =~ value ? true : false
  end

  def self.hostname?(value)
    /\A([0-9a-zA-Z]([0-9a-zA-Z-]{,61}[0-9a-zA-Z])?\.)+[a-zA-Z]{2,3}(\.[a-zA-Z]{2})?\z/ =~ value ? true : false
  end

  def self.ip_address?(value)
    /\A([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.\g<1>){3}\z/ =~ value ? true : false
  end

  def self.number?(value)
    /\A-?(0|[1-9][0-9]*)(\.[0-9]+)?\z/ =~ value ? true : false
  end

  def self.integer?(value)
    /\A-?(0|[1-9][0-9]*)\z/ =~ value ? true : false
  end

  def self.date?(value)
    /\A\d{4}-(0[1-9]|1[012])-(0[1-9]|[1-2][0-9]|3[01])\z/ =~ value ? true : false
  end

  def self.time?(value)
    /\A(0[1-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]\z/ =~ value ? true : false
  end

  def self.date_time?(value)
    case value
      when /\A\d{4}-(0[1-9]|1[012])-(0[1-9]|[1-2][0-9]|3[01])( |T)(0[1-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]\z/
        true
      else
        false
    end
  end
end
