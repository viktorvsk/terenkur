class EventType < ActiveRecord::Base
  include Permalinkable
  has_many :events
  after_destroy :update_events

  def self.keywords
    pluck(:keywords).map{ |k| k.split("\n") if k }.flatten.select(&:present?).map{ |k| k.mb_chars.downcase.strip.to_s }
  end

  def self.ok?
    keywords.size == keywords.uniq.size
  end

  def self.find_by_keyword(word)
    rel = where("keywords ~* ?", "(\n|^)(\s+?)?(#{word})(\r\n|\n|$)(\s+?)?")
    # Log if rel.size > 1
    rel.first
  end

  private
  def update_events
    self.events.each do |e|
      e.set_type
      e.save
    end
  end
end
