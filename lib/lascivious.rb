require 'engine'

module Lascivious

  # API key for Kiss Metrics. Available via https://www.kissmetrics.com/settings
  mattr_accessor :api_key
  @@api_key = ""
  ::ActionView::Base.send(:include, Lascivious)
  ::ActionController::Base.send(:include, Lascivious)

  # For use in config so we can do Lascivious.setup
  def self.setup
    yield self
  end

  # The main kiss metrics javascript & stuff
  def kiss_metrics_tag
    render :partial => "lascivious/header"
  end

  # The email beacon
  def kiss_metrics_email_beacon(email_address, variation, event_type = "Opened Email")
    render :partial => "lascivious/email_beacon", :locals => {
      :event_type => event_type,
      :api_key => kiss_metrics_api_key,
      :email => email_address,
      :variation => variation
    }
  end

  # Flash for all kiss metrics
  def kiss_metrics_flash
    messages = flash[:kiss_metrics]
    if messages.blank? || messages.empty?
      return nil
    end
    messages.map do |message|
      "_kmq.push(#{message.to_json});"
    end.join.html_safe
  end

  # Trigger an event at Kiss (specific: message of event_type 'record', e.g. User Signed Up)
  def kiss_record(value, properties={})
    kiss_metric :record, value, properties
  end

  # Set values (e.g. country: uk)
  def kiss_set(value)
    kiss_metric :set, value
  end

  # Strong identifier (e.g. user ID)
  def kiss_identify(value)
    kiss_metric :identify, value
  end

  # Weak identifier (e.g. cookie)
  def kiss_alias(value)
    kiss_metric :alias, value
  end

  # Record an arbitrary event-type and its value.
  def kiss_metric(event_type, value, properties = {})
    flash[:kiss_metrics] ||= []
    metric = [ event_type, value ]
    metric << properties if properties.any?
    flash[:kiss_metrics] << metric
  end

  # Get kiss metrics key
  def kiss_metrics_api_key
    return Lascivious.api_key
  end
end
