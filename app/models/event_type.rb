class EventType < ActiveRecord::Base
  include Permalinkable
  has_many :event_meta_types, dependent: :destroy
  has_many :events
  after_destroy :update_events

  def self.keywords
    pluck(:keywords).map{ |k| k.split("\n") if k }.flatten.select(&:present?).map(&:strip)
  end

  private
  def update_events
    self.events.each do |e|
      e.set_type
      e.save
    end
  end
end
