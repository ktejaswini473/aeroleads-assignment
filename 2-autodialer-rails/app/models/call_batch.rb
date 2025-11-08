class CallBatch < ApplicationRecord
  has_many :phone_calls, dependent: :destroy

  def enqueue_numbers_from_text(raw_numbers)
    raw_numbers.to_s.lines.each do |line|
      number = line.gsub(/\D/, "")
      next if number.blank?

      phone_calls.create!(phone_number: number, status: "queued")
    end
  end

  def stats
    {
      total: phone_calls.count,
      queued: phone_calls.where(status: "queued").count,
      calling: phone_calls.where(status: "calling").count,
      completed: phone_calls.where(status: "completed").count,
      failed: phone_calls.where(status: "failed").count
    }
  end
end
