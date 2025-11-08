class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text   :body,  null: false
      t.text   :source_prompt
      t.string :model_used

      t.timestamps
    end
  end
end
