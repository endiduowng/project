class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[twitter]

  validates :name, presence: true, length: {maximum: 50}

  mount_uploader :image, ImageUploader

  has_many :likes

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
end
