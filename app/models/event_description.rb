class EventDescription < ActiveRecord::Base
  belongs_to :event

  def set_type
    self.event.event_type = guess_type
  end

  def set_price
    p = self.price
    case p.try(:count)
    when 1
      event.min_price = p.first
      event.max_price = max_price = nil
    when 2
      event.min_price = p.first
      event.max_price = p.last
    else
      nil
    end
  end

  def guess_type
    binding.pry
    self.event_type.presence or EventType.all.sample
  end

  def price
    return unless content.present?
    currencies = %w{грн гр гривен uah руб рубл. грв грвн ₴ \$}.join('|')
    prices = content.mb_chars.downcase.to_s.delete(" ").scan(/(\d+)(?:#{currencies})/).flatten.map(&:to_i).sort
    prices.count > 1 ? [prices.first, prices.last] : [prices.first]
  end

  def event_type
    return unless content.present?
    keywords  = EventType.keywords.join('|')
    results   = content.mb_chars.downcase.to_s.scan(/#{keywords}/)
    counts    = Hash.new(0)
    results.each { |keyword| counts[keyword] += 1 }
    event_type = counts.max_by{ |k| k[1] }.first
    EventType.where('keywords LIKE ?', "%#{event_type}%").first
  end

end
