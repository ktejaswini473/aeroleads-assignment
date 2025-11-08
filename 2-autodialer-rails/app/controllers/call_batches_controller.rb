class CallBatchesController < ApplicationController
  def index
    @call_batches = CallBatch.order(created_at: :desc)
  end

  def show
    @call_batch = CallBatch.find(params[:id])
    @phone_calls = @call_batch.phone_calls.order(created_at: :asc)
  end

  def new
    @call_batch = CallBatch.new
  end

  def create
    @call_batch = CallBatch.new(call_batch_params)

    if @call_batch.save
      @call_batch.enqueue_numbers_from_text(params[:call_batch][:raw_numbers])
      redirect_to @call_batch, notice: "Batch created and numbers enqueued."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def start
    @call_batch = CallBatch.find(params[:id])
    client = TwilioClient.new

    # In assignment: they say use 1800 numbers for testing
    @call_batch.phone_calls.queued_status.find_each do |phone_call|
      client.call(phone_call)
    end

    redirect_to @call_batch, notice: "Started autodialer for queued numbers."
  end

  private

  def call_batch_params
    params.require(:call_batch).permit(:name, :notes)
  end
end
