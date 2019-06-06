class CreateIRecommends < ActiveRecord::Migration[5.1]
  def change
    create_table :i_recommends do |t|
      t.integer :item_id
      t.string :recommend_list

      t.timestamps
    end
  end
end
