class AiCommandInterpreter
  # Very simple "AI-style" rules. You can later swap this
  # for a real LLM call, but this already behaves like an agent.
  def self.handle(prompt)
    text = prompt.downcase

    if text.include?("call all queued")
      batch = CallBatch.order(created_at: :desc).first
      raise "No batches found" unless batch

      client = TwilioClient.new
      batch.phone_calls.queued_status.find_each do |phone_call|
        client.call(phone_call)
      end

      return {
        redirect_to: batch,
        message: "Started calling all queued numbers in the most recent batch."
      }
    end

    if text =~ /call\s+(\d{6,})/
      number = Regexp.last_match(1)
      batch = CallBatch.create!(name: "Single-call batch from AI prompt")
      phone_call = batch.phone_calls.create!(phone_number: number, status: "queued")

      client = TwilioClient.new
      client.call(phone_call)

      return {
        redirect_to: batch,
        message: "Calling #{number} based on your AI prompt."
      }
    end

    raise "Command not understood. Try: 'call all queued numbers' or 'call 1800123456'."
  end
end
