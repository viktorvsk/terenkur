class Event < ActiveRecord::Base
  acts_as_commentable
  include Permalinkable
  scope :real,    -> { joins(:days, :city, :event_type) }
  scope :today,   -> { where(days: {name: Date.today}) }
  scope :actual,  -> { where('days.name >= ?',Date.today) }
  after_create :create_event_description_with_content
  belongs_to :user
  belongs_to :event_type
  belongs_to :city
  has_many :event_days, dependent: :destroy
  has_many :days, through: :event_days
  has_one :event_description, dependent: :destroy, autosave: true
  has_many :images, as: :imageable, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :user, :teaser, :event_type, presence: true

  delegate :content, to: :event_description, allow_nil: true
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :event_description

  def preview(type=nil)
    images.present? ? images.first.attachment.url(type) : 'event-placeholder.png'
  end

  def display_content
    Sanitize.fragment(self.content, Sanitize::Config::BASIC).html_safe
  end

  def date
    days.map{ |day| I18n.localize(Date.parse(day.name), format: "%d %b") }.join(', ')
  end

  def date=(value)
    days.destroy_all if persisted?
    result = Day.parse(value)
    if result.present? and result != "Invalid date"
      to_assign = if result.kind_of?(String)
        Day.where(name: result).first_or_create! # Log
      else
        # Log invalid dates
        result = result.reject{ |d| d == "Invalid date" or not d.present? }

        result.map{ |day| Day.where(name: day).first_or_create! } # Log
        Day.where(name: result)
      end

      to_assign = [to_assign] if to_assign.kind_of?(Day)

      to_assign = to_assign.where('name >= ?', Date.today.to_s(:db)).order(:name).first(7) if to_assign.count > 7

      days << to_assign # Log
    end
  end

  def to_param
    permalink
  end

  def save_from_api!
    begin
      EventsWithoutDateLogger.info("Событию '#{self.name}' не присвоены даты.") unless self.days.present?
      save!
    rescue ActiveRecord::RecordInvalid => e
      FailedEventsLogger.error("Событие #{self.name} не добавлено. #{e.class}: #{e.message}")
    rescue NoMethodError => e
      FailedEventsLogger.error("Событие #{self.name} не добавлено. #{e.class}: #{e.message}")
    rescue Exception => e
      FailedEventsLogger.error("Событие #{self.name} не добавлено. #{e.class}: #{e.message}")
    end

  end

  def self.create_or_update_from_api(events, owner,  opts={})
    init_count = opts[:initial_count]
    if events.present?
      events_to_create = []
      updated_events = []

      transaction do

        events.each do |e|
          if event = Event.where(name: e['name']).first
            if event.user.admin?
              event.images.destroy_all
              updated_events << event if event.update(e) # Log error here
            else
              # and log error
            end
            next
          else
            event = owner.events.new(e)
            event.event_type = '' unless event.event_type.present?
            events_to_create << event
          end
        end

        events_to_create.map!(&:save_from_api!)
      end

      successfully_created_events = events_to_create.select{ |e| e }.count
      successfully_updated_events = updated_events.count
      not_processed_events_count  = init_count - successfully_created_events - successfully_updated_events

      "Из #{init_count} переданных событий #{successfully_created_events} были созданы, #{successfully_updated_events} обновлены. Не обработано #{not_processed_events_count} событий."
    else
      "Получено #{initial_events_count} событий. Ни одного не добавлено."
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

    et = guess(:event_type) if et.nil?

    self[:event_type_id] = et.id
  end

  def guess(what)
    case what
    when :event_type
      EventType.all.sample
    end
  end

  def teaser=(value)
    self[:teaser] = value.present? ? value.truncate(140) : "Описание в обработке..."
  end

  def city=(value)
    ct = if value.kind_of?(City)
      value
    elsif c = City.find_by_id(value)
      c
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
