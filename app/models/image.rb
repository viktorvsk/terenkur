class Image < ActiveRecord::Base
  mount_uploader :attachment, ImageUploader
  belongs_to :imageable, polymorphic: true

  def to_s
    attachment.to_s
  end
end
