class Event < ActiveRecord::Base
  belongs_to :user
  has_one :event_description, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :user, :event_description, :teaser, presence: true

  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :event_description

  def preview
    images.first
  end

  def advanced_descr
    event_description.content.except('main', 'time')
  end

  def descr(key)
    event_description.content[key] rescue nil
  end

  def description
    descr('main')
  end

  def description=(value)
    event_description.content['main'] = value
  end

  def time
    descr('time')
  end

  def time=(value)
    event_description.content['time'] = value
  end

end
