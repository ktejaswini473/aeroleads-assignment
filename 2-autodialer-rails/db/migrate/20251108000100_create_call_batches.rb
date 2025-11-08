class CreateCallBatches < ActiveRecord::Migration[7.1]
  def change
    create_table :call_batches do |t|
      t.string :name
      t.text :notes

      t.timestamps
    end
  end
end
