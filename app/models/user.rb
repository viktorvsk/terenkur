class User < ActiveRecord::Base
  require 'open-uri'

  has_one :avatar, as: :imageable, class_name: Image, dependent: :destroy
  has_many :events, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:vkontakte]
  accepts_nested_attributes_for :avatar

  def self.from_omniauth(auth)

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      image_url       = auth.extra.raw_info.photo_200_orig
      tempfile        = open(image_url)
      temp = Tempfile.new([auth.uid, '.jpg'])
      temp.binmode
      temp.write tempfile.read
      temp.close


      image_model     = Image.create!(attachment: temp)
      user.email      = auth.info.email || "#{auth.provider}_#{auth.uid}@#{auth.provider}.com"
      user.name       = auth.info.name
      user.avatar     = image_model
    end


  end

  def password_required?
    provider.present? ? false : super
  end

  def avatar_preview(type=nil)
    avatar ? avatar.attachment.url(type) : 'user-placeholder.png'
  end

end
