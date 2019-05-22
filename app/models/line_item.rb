class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart

  def total_price
    price_unit * quantity
  end
end
