class MediaFile < ApplicationRecord
  belongs_to :room
  has_one_attached :image

  before_save :deactivate_other_media_files, if: :will_save_change_to_active?
  after_update_commit :broadcast_media_file

  private

  def deactivate_other_media_files
    return unless active?

    room.media_files.where.not(id: id).update_all(active: false)
  end

  def broadcast_media_file
    if active?
      broadcast_replace_to "room_#{room.id}_media_files",
                           partial: "media_files/media_file",
                           target: "media-file-content",
                           locals: { media_file: self }
    else
      mf = MediaFile.new(title: "Próxima palestra em instantes")
      broadcast_replace_to "room_#{room.id}_media_files",
                           partial: "media_files/media_file",
                           target: "media-file-content",
                           locals: { media_file: mf }
    end

  end
end
