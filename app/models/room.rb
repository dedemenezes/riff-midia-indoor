class Room < ApplicationRecord
  has_many :presentations
  validates :name, presence: true
  scope :active, -> { where(visible: true) }
end
