class MediaFile < ApplicationRecord
  belongs_to :room
  has_one_attached :image
  validates :active, :image, presence: true
end
