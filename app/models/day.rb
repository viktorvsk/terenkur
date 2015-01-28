class Day < ActiveRecord::Base
  scope :actual,  -> { where('name >= ?', Date.today) }
  scope :today,   -> { where('name = ?', Date.today) }
  validates :name, presence: true, uniqueness: true, format: { with: /\A201[4567][\.\-\/](0?[1-9]|1[012])[\.\-\/](0?[1-9]|[12][0-9]|3[01])\z/ }
  has_many :event_days
  has_many :events, through: :event_days
  NORMALIZERS = {
    /(января|январь|янв\.?|янвр\.?)/        => 'Jan',
    /(ферваль|февраля|фев\.?|февр\.?)/      => 'Feb',
    /(марта|март|мар\.?|март\.?)/           => 'Mar',
    /(апрель|апреля|апр\.?)/                => 'Apr',
    /(май|мая|май\.?)/                      => 'May',
    /(июнь|июня|июн\.?)/                    => 'Jun',
    /(июль|июля|июл\.?)/                    => 'Jul',
    /(августа|август|авг\.?)/               => 'Aug',
    /(сентябрь|сентября|сен\.?)/            => 'Sep',
    /(октябрь|октября|окт\.?)/              => 'Oct',
    /(ноябрь|ноября|ноя\.?)/                => 'Nov',
    /(декабрь|декабря|дек\.?)/              => 'Dec',
    /((в )?(\d\d\:\d\d))/                   => '',
    /\s(год|года)\s/                        => '',
    /\s(пнд|втр|срд|чтв|птц|сбт|вск)/       => '',
    /\s(пн|вт|ср|чт|пт|сб|вс)/              => '',
    /сегодня/                               => -> { Date.today.to_s(:db) }.call ,
    /завтра/                                => -> { Date.tomorrow.to_s(:db) }.call ,
    /с(.+)по(.+)/                           => '\1 - \2',
    /\s+/                                   => ' ',
    /[,|-]\s?+\z/                           => '',
    /(года|год|г)/                          => ''
  }

  def to_s
    name
  end

  class << self

    def parse(str)
      return unless str.present?
      normalized  = normalize str
      value       = normalized.match(/,/) ? normalized.split(',') : normalized
      perform value
    end

    private
    def normalize(str)
      return unless str.present?
      str = str.mb_chars.strip.downcase.to_s
      NORMALIZERS.each do |k,v|
        str.gsub!(k,v)
      end
      str.strip
    end

    def perform(str)
      return unless str.present?
      begin
        if str.kind_of?(Array)
           dates = []
           str.each do |date|
            dates << perform(date)
           end
           dates.flatten.compact
        else
          monthes = %w[jan feb mar apr may jun jul aug sep oct nov dec].join('|')
          str.downcase!
          case
          when str.match(/\A(\d{1,2}\.\d{1,2})\z/)
            Date.parse("#{$1}.2015").to_s(:db)
          when str.match( /\A(\d{1,2})\s?+-\s?+(\d{1,2}) (#{monthes})\s?+(201[456])?\z/ )
            starts  = Date.parse("#$1 #$3 #$4")
            ends    = Date.parse("#$2 #$3 #$4")
            parse_range(starts, ends)
          when str.match( /(.*) - (.*)/ )
            starts  = Date.parse(perform("#$1"))
            ends    = Date.parse(perform("#$2"))
            parse_range(starts, ends)
          else
            Date.parse(str).to_s(:db)
          end
        end
      rescue ArgumentError, TypeError => e
        WrongDatesLog.error("#{e.message}: #{str}")
        nil
      end
    end

    def parse_range(starts, ends)
      starts  = starts - 1.year if starts > ends
      (starts..ends).to_a.map{ |d| d.to_s(:db) }
    end
  end

end