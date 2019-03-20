class Like < ApplicationRecord
  belongs_to :product
  belongs_to :user

  # validates :user_id, uniqueness: {scope: :product_id}
end
