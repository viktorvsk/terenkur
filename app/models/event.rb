class Event < ActiveRecord::Base
  include Permalinkable
  after_create :create_event_description_with_content
  belongs_to :user
  belongs_to :event_type
  belongs_to :city
  has_one :event_description, dependent: :destroy, autosave: true
  has_many :images, as: :imageable, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :user, :teaser, :event_type, presence: true

  delegate :content, to: :event_description
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :event_description

  def preview(type=nil)
    images.present? ? images.first.attachment.url(type) : 'event-placeholder.png'
  end

  def to_param
    permalink
  end

  def save_from_api!
    begin
      save!
    rescue ActiveRecord::RecordInvalid => e
      #binding.pry
    rescue NoMethodError => e
      #
    rescue Exception => e
      #binding.pry
    end

  end

  def event_type=(value)
    et = if value.kind_of?(EventType)
      value
    elsif t = EventType.where("LOWER(name) = ?", value.mb_chars.downcase.strip.to_s).first
      t
    elsif t = EventMetaType.where("LOWER(name) = ?", value.mb_chars.downcase.strip.to_s).first
      t.event_type
    end

    et = EventType.all.sample if et.nil?

    self[:event_type_id] = et.id
  end

  def teaser=(value)
    self[:teaser] = value.present? ? value.truncate(140) : "Описание в обработке..."
  end

  def city=(value)
    ct = if value.kind_of?(City)
      value
    else
      City.where("LOWER(name) = ?", value.mb_chars.downcase.strip.to_s).first
    end
    raise ActiveRecord::RecordNotFound if ct.nil?
    self[:city_id] = ct.id
  end

  def content=(value)
    if self.event_description.present?
      self.event_description.update :content => value
    else
      @content = value
    end

  end

  def images=(value)
    case value
    when Array
      value.map{ |image_url| self.image = image_url }
    when String
     self.image = value
    end
  end

  def image=(v)
    self.images.new(remote_attachment_url: v)
  end

  private
  def create_event_description_with_content
    self.create_event_description(content: @content)
  end

end
