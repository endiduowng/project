class AddPriceUnitToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :price_unit, :decimal
  end
end
