class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.integer :product_rating
      t.text :comment

      t.timestamps
    end
  end
end
