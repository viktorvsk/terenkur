class Day < ActiveRecord::Base
  scope :actual,  -> { where('name >= ?', Date.today) }
  scope :today,   -> { where('name = ?', Date.today) }
  validates :name, presence: true, uniqueness: true, format: { with: /\A201[4567][\.\-\/](0?[1-9]|1[012])[\.\-\/](0?[1-9]|[12][0-9]|3[01])\z/ }
  has_many :event_days
  has_many :events, through: :event_days

  def to_s
    name
  end

  def self.parse(value)
    value               = value.mb_chars.downcase.strip.to_s
    divider             = '[\.\-\/]'
    year                = '201[4567]'
    month               = '0?[1-9]|1[012]'
    day                 = '0?[1-9]|[12][0-9]|3[01]'
    time                = '(0?[0-9]|1[0-9]|2[0-3])[:-]([0-5][0-9])'
    time_optional       = "(\s?,?в?\s?#{time})?"
    time_range          = "#{time} - #{time}"
    time_range_optional = "(\s?,?в?\s?#{time_range})?"

    monthes   =   %w{января февраля марта апреля мая июня июля августа сентября октября ноября декабря}
    monthes   <<  %w{янв фев мар апр май июн июл авг сен окт ноя дек}
    monthes   <<  %w{янв фев мар апр май июн июл авг сен окт ноя дек}.map{ |m| "#{m}\." }
    monthes   <<  %w{янв февр марта апр май июн июл авг сен окт нояб дек}.map{ |m| "#{m}\." }
    monthes   <<  %w{январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь}
    monthes   =   monthes.flatten.join('|')

    if value =~ /\A#{year}#{divider}(#{month}#){divider}(#{day})\z/
      Date.parse(value).to_s(:db)
    elsif value =~ /:::/
      vals = value.split(":::").reject(&:blank?)
      vals.map{ |d| parse(d) }.flatten
    elsif value =~ /\A(#{day}) (#{monthes}) - (#{day}) (#{monthes})( (#{year}))?(\s?,?в?\s?#{time}?)?\z/ or
          value =~ /\A(#{day}) (#{monthes}) #{year} - (#{day}) (#{monthes})( (#{year}))?(\s?,?в?\s?#{time}?)?\z/ or
          value =~ /\Aс (#{day}) (#{monthes}) по (#{day}) (#{monthes})\z/ or
          value =~ /\Aс (#{day}) (#{monthes}) #{year} по (#{day}) (#{monthes}) #{year}\z/
      date_start  = Date.parse("#{$1} #{mon($2)} #{$5}")
      date_end    = Date.parse("#{$3} #{mon($4)} #{$5}")
      date_start  = date_start - 1.year if date_start > date_end
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /\A(#{day}#{divider}#{month}) - (#{day}#{divider}#{month})\z/
      date_start  = Date.parse("#{$1}")
      date_end    = Date.parse("#{$2}")
      date_start  = date_start - 1.year if date_start > date_end
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /\A(#{monthes}) (#{day}) [а-я]+? - (#{monthes}) (#{day}) [а-я]+?\z/
      date_start  = Date.parse("#{$2} #{mon($1)}")
      date_end    = Date.parse("#{$4} #{mon($3)}")
      date_start  = date_start - 1.year if date_start > date_end
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /\A(#{day}) (#{monthes})#{time_optional}\z/ or
          value =~ /\A(#{day})#{divider}(#{month})#{time_optional}\z/ or
          value =~ /\A(#{day})#{divider}(#{month})#{time_range_optional}\z/ or
          value =~ /\A(#{day}) (#{monthes})\z/ or
          value =~ /\A(#{day}) (#{monthes}) (#{year})\z/ or
          value =~ /\A(#{day}) (#{monthes}) (#{year}) г, #{time_optional}\z/
      Date.parse("#{$1} #{mon($2)}").to_s(:db)
    elsif value =~ /\A(#{day})#{divider}(#{day}) (#{monthes}) #{year} года\z/ or
          value =~ /\A(#{day})#{divider}(#{day}) (#{monthes})( #{year} года)?\z/
      date_start  = Date.parse("#{$1} #{mon($3)}")
      date_end    = Date.parse("#{$2} #{mon($3)}")
      date_start  = date_start - 1.year if date_start > date_end
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /\Aзавтра в #{time}\z/
      Date.tomorrow.to_s(:db)
    elsif value =~ /\Aсегодня в #{time}\z/
      Date.today.to_s(:db)
    elsif value =~ /\Aвчера в #{time}\z/
      Date.yesterday.to_s(:db)
    elsif value =~ /\A(#{day}) (#{monthes}) в #{time} - (#{day}) (#{monthes}) в #{time}\z/
      date_start  = Date.parse("#{$1} #{mon($2)}")
      date_end    = Date.parse("#{$5} #{mon($6)}")
      date_start  = date_start - 1.year if date_start > date_end
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /\Aсегодня в #{time} - (#{day}) (#{monthes}) в #{time}\z/
      date_start  = Date.today
      date_end    = Date.parse("#{$3} #{mon($4)}")
      date_start  = date_start - 1.year if date_start > date_end
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /\Aзавтра в #{time} - (#{day}) (#{monthes}) в #{time}\z/
      date_start  = Date.tomorrow
      date_end    = Date.parse("#{$3} #{mon($4)}")
      date_start  = date_start - 1.year if date_start > date_end
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /\Aзавтра в #{time} - завтра в #{time}\z/
      Date.tomorrow.to_s(:db)
    elsif value =~ /\Aсегодня в #{time} - сегодня в #{time}\z/
      Date.today.to_s(:db)
    elsif value =~ /\Aсегодня в #{time} - завтра в #{time}\z/
      date_start  = Date.today
      date_end    = Date.tomorrow
      (date_start..date_end).to_a.map{ |d| d.to_s(:db) }
    elsif value =~ /,/
      vals = value.split(",").reject(&:blank?)
      vals.map{ |d| parse(d) }.flatten
    else
      "Invalid date"
    end

  end

  def self.mon(value)
    case value
    when /\A(янв|января|январь|янв\.)\Z/
      "Jan"
    when /\A(фев|февраля|февраль|фев\.|февр.)\Z/
      "Feb"
    when /\A(мар|марта|март|мар\.|марта.)\Z/
      "Mar"
    when /\A(апр|апреля|апрель|апр\.)\Z/
      "Apr"
    when /\A(май|мая|май|май\.)\Z/
      "May"
    when /\A(июн|июня|июнь|июн\.)\Z/
      "Jun"
    when /\A(июл|июля|июль|июл\.)\Z/
      "Jul"
    when /\A(авг|августа|август|авг\.)\Z/
      "Aug"
    when /\A(сен|сентября|сентябрь|сен\.)\Z/
      "Sep"
    when /\A(окт|октября|октябрь|окт\.)\Z/
      "Oct"
    when /\A(ноя|ноября|ноябрь|ноя\.)\Z/
      "Nov"
    when /\A(дек|декабря|декабрь|дек\.)\Z/
      "Dec"
    end
  end

end
