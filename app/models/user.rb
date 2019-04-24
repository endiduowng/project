require './lib/recommendation.rb'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[twitter]

  validates :name, presence: true, length: {maximum: 50}

  mount_uploader :image, ImageUploader

  has_many :likes
  has_many :products, through: :likes
  has_many :orders

  has_many :reviews

  has_many :messages
  has_many :conversations, foreign_key: :sender_id

  include Recommendation

  # nhan dang tai khoan twitter
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.image = auth.info.image.gsub!("_normal", "")
      user.uid = auth.uid
      user.provider = auth.provider
    end
  end

  def likeds
    return self.reviews.select{|product| product.product_rating >= 3}
  end

  def dislikeds
    return self.reviews.select{|product| product.product_rating < 3}
  end

  def similarity_with(user)
    # Array#& is the set intersection operator.
    agreements = (self.likeds & user.likeds).size
    agreements += (self.dislikeds & user.dislikeds).size

    disagreements = (self.likeds & user.dislikeds).size
    disagreements += (self.dislikeds & user.likeds).size

    # Array#| is the set union operator
    total = (self.likeds + self.dislikeds) | (user.likeds + user.dislikeds)

    return (agreements - disagreements) / total.size.to_f
  end

  def prediction_for(product)
    hive_mind_sum = 0.0
    rated_by = product.liked_by.size + product.disliked_by.size

    product.liked_by.each { |u| hive_mind_sum += self.similarity_with(u) }
    product.disliked_by.each { |u| hive_mind_sum -= self.similarity_with(u) }

    return hive_mind_sum / rated_by.to_f
  end
end
