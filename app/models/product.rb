require "elasticsearch/model"

class Product < ApplicationRecord

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  searchkick

  has_many :likes

  def is_liked user
    if user
      Like.find_by(user_id: user.id, product_id: id)
    end
  end
end
