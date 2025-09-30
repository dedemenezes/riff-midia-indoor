class Presentation < ApplicationRecord
  CATEGORIES = [
    "Exibição",
    "Masterclass",
    "Rodadas de Negócios",
    "Round table",
    "Seminars",
    "Workshops"
  ]

  belongs_to :room
  has_one_attached :image

  before_save :deactivate_other_presentations, if: :will_save_change_to_active?
  after_update_commit :broadcast_presentation
  after_update_commit :broadcast_next_presentation

  private

  def deactivate_other_presentations
    return unless active?

    room.presentations.where.not(id: id).update_all(active: false)
  end

  def broadcast_next_presentation
    sorted_presentations = room.presentations.order(start_time: :asc)
    active_presentation_index = sorted_presentations.index(self)
    if active_presentation_index
      next_presentation = sorted_presentations[active_presentation_index + 1]
      broadcast_replace_to "room_#{room.id}_presentations",
                           partial: "presentations/next_presentation",
                           target: "next-presentation",
                           locals: { next_presentation: next_presentation }
    end
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

    broadcast_replace_to "presentations",
                         partial: "presentations/presentation_row",
                         locals: { presentation: self },
                         target: "presentation_#{self.id}"
  end
end
