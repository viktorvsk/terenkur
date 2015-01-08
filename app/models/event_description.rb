class EventDescription < ActiveRecord::Base
  belongs_to :event
  serialize :content, Hash
end
