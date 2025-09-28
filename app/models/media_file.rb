class MediaFile < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :room
  has_one_attached :image

  after_update_commit :broadcast_media_file


  private

  def broadcast_media_file
    broadcast_replace_to "room_#{room.id}_media_files",
                         partial: "media_files/media_file",
                         target: dom_id(self),
                         locals: { media_file: self }
  end
end
