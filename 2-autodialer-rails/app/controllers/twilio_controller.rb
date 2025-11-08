class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Twilio hits this URL to know what to say during the call
  def twiml
    message = params[:message].presence || "Hello, this is a test call from the autodialer."
    response = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Response>
        <Say voice="Polly.Joanna">#{ERB::Util.h(message)}</Say>
      </Response>
    XML

    render xml: response
  end

  # Twilio sends call status updates here
  def status_callback
    phone_call = PhoneCall.find_by(twilio_sid: params[:CallSid])
    return head :ok unless phone_call

    case params[:CallStatus]
    when "completed"
      phone_call.update(status: "completed")
    when "failed", "busy", "no-answer"
      phone_call.update(status: "failed")
    end

    head :ok
  end
end
