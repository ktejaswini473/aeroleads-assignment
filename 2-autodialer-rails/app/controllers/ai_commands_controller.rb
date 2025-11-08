class AiCommandsController < ApplicationController
  def create
    prompt = params[:prompt].to_s
    result = AiCommandInterpreter.handle(prompt)

    redirect_to result[:redirect_to], notice: result[:message]
  rescue => e
    redirect_back fallback_location: root_path, alert: "Error: #{e.message}"
  end
end
