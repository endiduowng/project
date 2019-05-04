class CreateRecommends < ActiveRecord::Migration[5.1]
  def change
    create_table :recommends do |t|
      t.integer :user_id
      t.string :recommend_id

      t.timestamps
    end
  end
end
