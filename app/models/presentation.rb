class Presentation < ApplicationRecord
  belongs_to :room
  has_one_attached :image

  before_save :deactivate_other_presentations, if: :will_save_change_to_active?
  after_update_commit :broadcast_presentation

  private

  def deactivate_other_presentations
    return unless active?

    room.presentations.where.not(id: id).update_all(active: false)
  end

  def broadcast_presentation
    if active?
      broadcast_replace_to "room_#{room.id}_presentations",
                           partial: "presentations/presentation",
                           target: "media-file-content",
                           locals: { presentation: self }
    else
      mf = Presentation.new(title: "Próxima palestra em instantes")
      broadcast_replace_to "room_#{room.id}_presentations",
                           partial: "presentations/presentation",
                           target: "media-file-content",
                           locals: { presentation: mf }
    end

  end
end
