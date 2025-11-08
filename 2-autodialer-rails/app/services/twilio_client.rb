require "twilio-ruby"

class TwilioClient
  def initialize
    @account_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
    @auth_token  = ENV.fetch("TWILIO_AUTH_TOKEN")
    @from_number = ENV.fetch("TWILIO_FROM_NUMBER") # your Twilio number
    @client      = Twilio::REST::Client.new(@account_sid, @auth_token)
  end

  def call(phone_call, message: "This is a test autodialer call for the AeroLeads assignment.")
    call = @client.calls.create(
      from: @from_number,
      to: phone_call.phone_number,
      url: twiml_url(message),
      status_callback: status_callback_url,
      status_callback_event: %w[completed failed no-answer busy]
    )

    phone_call.update!(
      status: "calling",
      twilio_sid: call.sid,
      called_at: Time.current
    )
  rescue => e
    phone_call.update!(
      status: "failed",
      error_message: e.message
    )
  end

  private

  def twiml_url(message)
    Rails.application.routes.url_helpers.twilio_twiml_url(
      message: CGI.escape(message),
      host: ENV.fetch("APP_HOST", "localhost:3000")
    )
  end

  def status_callback_url
    Rails.application.routes.url_helpers.twilio_status_callback_url(
      host: ENV.fetch("APP_HOST", "localhost:3000")
    )
  end
end
