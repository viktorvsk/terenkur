class City < ActiveRecord::Base
  include Permalinkable
  has_many :events, dependent: :destroy
end
