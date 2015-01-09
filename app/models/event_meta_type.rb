class EventMetaType < ActiveRecord::Base
  belongs_to :event_type
  validates :name, :event_type, presence: true, uniqueness: true

  def event_type=(value)
    et = (value.kind_of?(EventType) ? value : EventType.where("LOWER(name) = ?", value.downcase).first)
    raise ActiveRecord::RecordNotFound, "Event Type not found" if et.nil?
    self[:event_type_id] = et.id
  end
end
