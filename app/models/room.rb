class Room < ApplicationRecord
  has_many :media_files
  validates :name, presence: true
end
