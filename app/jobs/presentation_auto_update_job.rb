class PresentationAutoUpdateJob < ApplicationJob
  ACTIVATION_WINDOW  = 10.minutes
  DEACTIVATION_WINDOW = 10.minutes
  queue_as :default

  def perform(*args)
    @current_time = Time.current
    Rails.logger.info "[RAILS::LOGGER::INFO] Auto-update cycle starting at #{@current_time}"

    affected_rooms = Set.new

    # Process each room independently
    Room.find_each do |room|
      changed = process_room(room)
      affected_rooms << room if changed
    end

    # Broadcast updates for affected rooms
    affected_rooms.each do |room|
      broadcast_room_presentations(room)
      broadcast_individual_room_page(room)
      Rails.logger.info "[AUTO-UPDATE] Broadcasted updates for #{room.name}"
    end

    Rails.logger.info "[RAILS::LOGGER::INFO] Auto-update cycle completed"
  end

  private

  def process_room(room)
    changed = false
    current_active = room.presentations.where(active: true).first

    if current_active && should_deactivate?(current_active)
      Rails.logger.info "[AUTO-UPDATE] Room #{room.id}: Deactivating '#{current_active.title}' (ends at #{current_active.end_time})"
      current_active.update_columns(active: false, updated_at: Time.current)
      changed = true

      next_presentation = room.presentations
                              .where(active: false)
                              .where("start_time > ?", @current_time)
                              .order(start_time: :asc)
                              .first

      if next_presentation
        Rails.logger.info "[AUTO-UPDATE] Room #{room.id}: Activating next '#{next_presentation.title}' (starts at #{next_presentation.start_time})"
        next_presentation.update_columns(active: true, updated_at: Time.current)
      else
        Rails.logger.warn "[AUTO-UPDATE] Room #{room.id}: No upcoming presentations to activate"
      end
    elsif current_active.nil?
      next_presentation = room.presentations
                              .where(active: false)
                              .where("start_time >= ?", @current_time)
                              .order(start_time: :asc)
                              .first

      if next_presentation
        Rails.logger.info "[AUTO-UPDATE] Room #{room.id}: No active presentation, activating '#{next_presentation.title}'"
        next_presentation.update_columns(active: true, updated_at: Time.current)
        changed = true
      else
        Rails.logger.debug "[AUTO-UPDATE] Room #{room.id}: No presentations to activate"
      end
    end

    changed
  end

  def should_deactivate?(presentation)
    # Deactivate 10 minutes before end_time
    presentation.end_time - DEACTIVATION_WINDOW <= @current_time
  end

  # CHANGED: Extracted from model - broadcasts to index page (presentations table)
  def broadcast_room_presentations(room)
    I18n.with_locale(:'pt-BR') do
      now = Time.current

      active_presentation = room.presentations.where("start_time <= ? AND end_time >= ?", now, now).first

      upcoming_presentations = room.presentations
                                   .where("start_time > ?", now)
                                   .order(start_time: :asc)
                                   .limit(2)

      presentations_to_display = []
      presentations_to_display << active_presentation if active_presentation
      presentations_to_display.concat(upcoming_presentations.to_a)
      presentations_to_display = presentations_to_display.uniq.first(2)

      Turbo::StreamsChannel.broadcast_replace_to(
        "presentations",
        target: ActionView::RecordIdentifier.dom_id(room, :presentations),
        partial: "rooms/presentations",
        locals: { room: room, presentations: presentations_to_display }
      )
    end
  end

  # CHANGED: New method - broadcasts to individual room/:id pages
  # Replaces the two model callbacks: broadcast_presentation and broadcast_next_presentation
  def broadcast_individual_room_page(room)
    I18n.with_locale(:'pt-BR') do
      active_presentation = room.presentations.where(active: true).first

      # Broadcast current presentation content
      if active_presentation
        Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{room.id}_presentations",
          partial: "presentations/content",
          target: "presentation-content",
          locals: { presentation: active_presentation }
        )

        # Broadcast next presentation
        sorted = room.presentations.order(start_time: :asc)
        active_index = sorted.index(active_presentation)
        next_presentation = sorted[active_index + 1] if active_index
        if next_presentation
          Turbo::StreamsChannel.broadcast_replace_to(
            "room_#{room.id}_presentations",
            partial: "presentations/next_presentation",
            target: "next-presentation",
            locals: { next_presentation: next_presentation }
          )
        end
      else
        # No active presentation - show skeleton/placeholder
        skeleton = Presentation.new(
          title: "Próxima palestra em instantes",
          presenter_name: nil,
          start_time: nil,
          end_time: nil
        )

        Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{room.id}_presentations",
          partial: "presentations/content",
          target: "presentation-content",
          locals: { presentation: skeleton }
        )
      end
    end
  end
end
