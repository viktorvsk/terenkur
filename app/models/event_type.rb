class EventType < ActiveRecord::Base
  include Permalinkable
  has_many :event_meta_types, dependent: :destroy
  has_many :events

  def self.keywords
    pluck(:keywords).map{ |k| k.split("\n") if k }.flatten.select(&:present?).map(&:strip)
  end
end
