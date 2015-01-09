class EventType < ActiveRecord::Base
  include Permalinkable
  has_many :event_meta_types, dependent: :destroy
  has_many :events
end
