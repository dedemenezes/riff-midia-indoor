class Presentation < ApplicationRecord
  include ActionView::RecordIdentifier

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
  after_update_commit :broadcast_room_presentations
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
                           partial: "presentations/content",
                           target: "presentation-content",
                           locals: { presentation: self }
    else
      mf = Presentation.new(
        id: self.id,
        title: "Próxima palestra em instantes",
        presenter_name: nil,
        start_time: nil,
        end_time: nil
      )
      broadcast_replace_to "room_#{room.id}_presentations",
                           partial: "presentations/content",
                           target: "presentation-content",
                           locals: { presentation: mf }
    end
      #  target: "presentation-#{self.id}",

    # broadcast_replace_to "presentations",
    #                      partial: "presentations/presentation_row",
    #                      locals: { presentation: self },
    #                      target: "presentation_#{self.id}"
  end

  def broadcast_room_presentations
    I18n.with_locale(:'pt-BR') do
      now = Time.current

      # Find active presentation for this room
      active_presentation = room.presentations.find do |p|
        p.start_time <= now && p.end_time >= now
      end

      # Find upcoming presentations for this room
      upcoming_presentations = room.presentations
                                   .where("start_time > ?", now)
                                   .order(start_time: :asc)
                                   .limit(2)

      # Build the array of presentations to display (max 2)
      presentations_to_display = []
      presentations_to_display << active_presentation if active_presentation
      presentations_to_display.concat(upcoming_presentations.to_a)
      presentations_to_display = presentations_to_display.uniq.first(2)

      # Broadcast replacement to the room's presentations wrapper
      # binding.b
      broadcast_replace_to "presentations",
                          target: dom_id(room, :presentations),
                          partial: "rooms/presentations",
                          locals: { room: room, presentations: presentations_to_display }
    end
  end
end
