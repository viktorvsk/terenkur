class Event < ActiveRecord::Base
  acts_as_commentable
  include Permalinkable
  scope :real,    -> { joins(:days, :city, :event_type) }
  scope :today,   -> { where(days: {name: Date.today}) }
  scope :actual,  -> { where('days.name >= ?',Date.today) }
  belongs_to :user
  belongs_to :event_type
  belongs_to :city
  has_many :event_days, dependent: :destroy
  has_many :days, through: :event_days
  has_many :orders, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :user, :teaser, :event_type, presence: true
  #validates :days, presence: true, allow_nil: true
  validates_numericality_of :min_price, presence: true, allow_nil: true
  validates_numericality_of :max_price, :greater_than_or_equal_to => :min_price, allow_nil: true, :unless => Proc.new {|event| event.min_price.nil? }

  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  def to_param
    permalink
  end


  def preview(type=nil)
    images.present? ? images.first.attachment.url(type) : 'event-placeholder.png'
  end

  def display_content
    text = self.content
    Conf.get_all('deletions').values.each{ |v| text.gsub!(v, '') } if text.present?
    Sanitize.fragment(text, Sanitize::Config::BASIC).html_safe
  end

  ### For API ###

  def save_from_api!
    begin
      EventsWithoutDateLogger.info("Событию '#{self.name}' не присвоены даты.") unless self.days.present?
      save!
    rescue ActiveRecord::RecordInvalid => e
      FailedEventsLogger.error("Событие #{self.name} не добавлено. #{e.class}: #{e.message}")
      false
    rescue NoMethodError => e
      FailedEventsLogger.error("Событие #{self.name} не добавлено. #{e.class}: #{e.message}")
      false
    rescue Exception => e
      FailedEventsLogger.error("Событие #{self.name} не добавлено. #{e.class}: #{e.message}")
      false
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
            if event.user == owner
              #event.images.destroy_all
              e.delete('image')
              e.delete('images')
              e.delete(:images)
              e.delete(:image)
              event.event_type  = '' unless event.event_type.present?
              event.price       = '' unless event.price.present?
              event.city        = '' unless event.city.present?
              begin
                updated_events << event if event.update(e)
              rescue ActiveRecord::RecordInvalid => ex
                FailedEventsLogger.error("Событие #{event.name} не обновлено: #{ex.class}: #{ex.message}")
              end
            else
              FailedEventsLogger.error("Попытка обновить чужое событие: #{event.name} от имени #{owner.email}")
            end
            next
          else
            begin
              event = owner.events.new(e)
            rescue ActiveRecord::RecordInvalid => ex
              FailedEventsLogger.error("#{ex.class}: #{ex.message} для #{e['name']}")
              next
            end
            event.event_type  = '' unless event.event_type.present?
            event.price       = '' unless event.price.present?
            event.city        = '' unless event.city.present?
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

  ### End API ###

  def set_type
    self.event_type = guess_type
  end

  def set_price
    p = price_from_content
    case p.try(:count)
    when 1
      self.min_price = p.first
      self.max_price = max_price = nil
    when 2
      self.min_price = p.first
      self.max_price = p.last
    else
      nil
    end
  end

  def guess_type
    event_type_from_content.presence or EventType.all.sample
  end

  ### Virtual attributes ###
  def images=(value)
    case value
    when Array
      value.map{ |image_url| self.image = image_url }
    when String
     self.image = value
    end
  end

  def image=(v)
    begin
      Timeout::timeout(3) do
        self.images.new(remote_attachment_url: v)
      end
    rescue Timeout::Error
      SlowImagesLog.warn("Slow Image: #{v}")
      nil
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
    ct = City.first if ct.nil?
    self[:city_id] = ct.id
  end

  def event_type=(value)
    et = if value.kind_of?(EventType)
      value
    elsif value =~ /\A\d+\z/
      EventType.find(value)
    elsif value and t = EventType.where("LOWER(name) = ?", value.mb_chars.downcase.strip.to_s).first
      t
    elsif  value and t = EventType.find_by_keyword(value)
      t
    end

    et = guess_type if et.nil?

    self[:event_type_id] = et.id
  end

  def price
    return nil if min_price.nil? and max_price.nil?
    min, max = self.min_price.to_i, self.max_price.to_i

    if min > 0 and max > min
      "от #{min} до #{max} #{city.currency}"
    elsif min > 0 and max <= min
      "от #{min} #{city.currency}"
    elsif min == 0 and max >= 0
      "бесплатно - #{max} #{city.currency}"
    else
      nil
    end
  end

  def price=(value=nil)
    set_price
  end

  def date
    days.map{ |day| I18n.localize(Date.parse(day.name), format: "%e %b") }.join(', ')
  end

  def date=(value)
    days.destroy_all if persisted?
    result = Day.parse(value)
    if result.present? and result != "Invalid date"
      to_assign = if result.kind_of?(String)
        begin
          Day.where(name: result).first_or_create!
        rescue ActiveRecord::RecordInvalid => ex
          WrongDatesLog.error("#{self.name} имеет неверную дату: #{result}")
        end
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

  ### End of virtual attributes ###


  def price_from_content
    return unless content.present?
    currencies = %w{грн гр гривен uah руб рубл\. грв грвн ₴ \$ uah грн\. гривень грвн\. грв\. р р\. р рубл. грн. грвн.}.join('|')
    prices = self.content.mb_chars.downcase.to_s.delete(" ").scan(/(\d+)(?:#{currencies})/).flatten.map(&:to_i).sort
    prices.count > 1 ? [prices.first, prices.last] : [prices.first]
  end

  def event_type_from_content
    return unless content.present?
    keywords  = EventType.keywords.join('|')
    results   = content.mb_chars.downcase.to_s.scan(/#{keywords}/)
    counts    = Hash.new(0)
    results.each { |keyword| counts[keyword] += 1 }
    event_type = counts.max_by{ |k| k[1] }.try(:first)
    return unless event_type
    EventType.where('keywords LIKE ?', "%#{event_type}%").first
  end

  def self.vk_to_events(events, city)
    events.map do |event|
      s = Time.at(event['start_date'].to_i).to_date.strftime("%d %b %Y")
      e = Time.at(event['finish_date'].to_i).to_date.strftime("%d %b %Y")
      date = "#{s} - #{e}"
      r = {
           "name"          => event['name'],
           "content"       => event['description'],
           "date"          => date,
           "image"         => event['photo_big'],
           "teaser"        => event['description'],
           "city"          => city.name,
           "event_type"    => event['event_type']
          }
      r['address'] = event['place']['address'] if event['place'].present?
      r
    end
  end

  def self.from_vk_by_words(words, city_id)
    result  = []
    words.each do |word|
      url = "https://api.vk.com/method/groups.search?q=#{word}&access_token=#{Conf['vk.token']}&count=1000&future=1&city_id=#{city_id}&type=event"
      url = URI.encode(url)
      begin
        response = RestClient.get(url)
      rescue RestClient
        print '-'
        next
      end
      begin
        response_json_events = JSON.parse(response)['response'][1..-1]
      rescue NoMethodError
        print '-'
        next
      end
      response_json_events.map!{ |e| e['event_type'] = word; e }
      result << response_json_events
      print '+'
      sleep 0.333
    end
    evs = result.flatten.select(&:present?).uniq{ |e| e['name'] }
    ids = evs.map{ |e| e['gid'] }
    result_events = []
    ids.in_groups_of(500, false) do |ids_group|
      i = ids_group.join(',')
      resp = RestClient.post("https://api.vk.com/method/groups.getById",
        group_ids: i,
        fields: 'place,description,members_count,start_date,finish_date')
      begin
        result_events << JSON.parse(resp)['response']
      rescue NoMethodError
        print '-'
        next
      end
      print '+'
      sleep 0.333
    end
    result_events.flatten!
    result_events.reject!{ |e| e['members_count'].to_i < 25 }
    result_events.map do |e|
      e['event_type'] = evs.detect{ |ev| ev['gid'] == e['gid'] }['event_type']
      e
    end

    result_events
  end


end
