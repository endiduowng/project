require './lib/recommendation.rb'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[twitter]

  validates :name, presence: true, length: {maximum: 50}

  mount_uploader :image, ImageUploader

  has_many :favorites
  has_many :products, through: :favorites
  has_many :orders

  has_many :reviews

  has_many :messages
  has_many :conversations, foreign_key: :sender_id

  recommends :products

  include Recommendation

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

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

  def similarity_with(user)
    # Array#& is the set intersection operator.
    agreements = (self.likes & user.likes).size
    agreements += (self.dislikes & user.dislikes).size

    disagreements = (self.likes & user.dislikes).size
    disagreements += (self.dislikes & user.likes).size

    # Array#| is the set union operator
    total = (self.likes + self.dislikes) | (user.likes + user.dislikes)

    return (agreements - disagreements) / total.size.to_f
  end

  def prediction_for(item)
    hive_mind_sum = 0.0
    rated_by = item.liked_by.size + item.disliked_by.size

    item.liked_by.each { |u| hive_mind_sum += self.similarity_with(u) }
    item.disliked_by.each { |u| hive_mind_sum -= self.similarity_with(u) }

    return hive_mind_sum / rated_by.to_f
  end
end
