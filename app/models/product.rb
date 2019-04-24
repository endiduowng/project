require "elasticsearch/model"

class Product < ApplicationRecord

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  searchkick

  has_many :likes
  has_many :users, through: :likes

  has_many :line_items
  has_many :reviews

  before_destroy :check_if_has_line_item

  paginates_per 8

  def is_liked user
    if user
      Like.find_by(user_id: user.id, product_id: id)
    end
  end

  def liked_by
    return self.reviews.select {|user| user.product_rating >= 3}
  end

  def disliked_by
    return self.reviews.select {|user| user.product_rating < 3}
  end

private

    def check_if_has_line_item
        if line_items.empty?
            return true
        else
            errors.add(:base, 'This product has a LineItem')
            return false
        end
    end
end
