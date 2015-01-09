class EventDescription < ActiveRecord::Base
  before_create :sanitize_content
  belongs_to :event

  private
  def sanitize_content
  end
end
