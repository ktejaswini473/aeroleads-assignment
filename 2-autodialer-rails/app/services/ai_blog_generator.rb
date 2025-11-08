require "net/http"
require "json"

class AiBlogGenerator
  # Very simple wrapper around an LLM API (example: OpenAI)
  def self.generate(title, extra_details: "")
    api_key = ENV.fetch("OPENAI_API_KEY")
    uri = URI("https://api.openai.com/v1/chat/completions")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    })

    request.body = {
      model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "You are a helpful technical blog writer." },
        {
          role: "user",
          content: "Write a detailed programming blog post about '#{title}'. Extra details: #{extra_details}. " \
                   "Use headings, bullet points, and code examples where useful."
        }
      ]
    }.to_json

    response = http.request(request)
    json = JSON.parse(response.body)
    json.dig("choices", 0, "message", "content") || "AI did not return any content."
  rescue => e
    Rails.logger.error("AI error: #{e.message}")
    "AI generation failed: #{e.message}"
  end
end
