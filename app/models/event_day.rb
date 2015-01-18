class EventDay < ActiveRecord::Base
  belongs_to :event
  belongs_to :day
end
