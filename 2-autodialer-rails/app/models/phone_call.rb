class PhoneCall < ApplicationRecord
  belongs_to :call_batch

  enum status: {
    queued: "queued",
    calling: "calling",
    completed: "completed",
    failed: "failed"
  }, _suffix: :status

  validates :phone_number, presence: true
end
