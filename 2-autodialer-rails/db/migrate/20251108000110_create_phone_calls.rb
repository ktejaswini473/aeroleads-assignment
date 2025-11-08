class CreatePhoneCalls < ActiveRecord::Migration[7.1]
  def change
    create_table :phone_calls do |t|
      t.references :call_batch, null: false, foreign_key: true
      t.string :phone_number, null: false
      t.string :status, null: false, default: "queued"
      t.string :twilio_sid
      t.text :error_message
      t.datetime :called_at

      t.timestamps
    end
  end
end
