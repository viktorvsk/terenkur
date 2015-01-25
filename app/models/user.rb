class User < ActiveRecord::Base
  require 'open-uri'
  acts_as_commentable
  acts_as_token_authenticatable
  has_one :avatar, as: :imageable, class_name: Image, dependent: :destroy, :autosave => true
  has_many :events, dependent: :destroy
  has_many :orders, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:vkontakte]
  accepts_nested_attributes_for :avatar
  enum sex: [ :male, :female ]

  def avatar=(value)
    avatar.attachment = value
  end

  def display_about
    Sanitize.fragment(self.about, Sanitize::Config::BASIC).html_safe
  end

  def clients
    events_ids = events.pluck(:id)
    users_ids = Order.where(event: events_ids).pluck(:user_id)
    User.where(id: users_ids)
  end

  def events_of(user)
    ordered_events = orders.pluck(:event_id)
    result = ordered_events & user.events.pluck(:id)
    Event.where(id: result)
  end

  def self.from_omniauth(auth)

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      image_url       = auth.extra.raw_info.photo_200_orig
      user.email      = auth.info.email || "#{auth.provider}_#{auth.uid}@#{auth.provider}.com"
      user.name       = auth.info.name
      user.build_avatar(remote_attachment_url: image_url)
    end


  end

  def password_required?
    provider.present? ? false : super
  end

  def avatar_preview(type=nil)
    avatar ? avatar.attachment.url(type) : 'user-placeholder.png'
  end

end
