class PresentationAutoUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @current_time = Time.current
    Rails.logger.info "[RAILS::LOGGER::INFO] Auto-update cycle starting at #{@current_time}"

    expired = expired_presentations
    current = current_presentations

    Rails.logger.info "[AUTO-UPDATE] Expired: #{expired.pluck(:id, :title, :active)}"
    Rails.logger.info "[AUTO-UPDATE] To activate: #{current.pluck(:id, :title, :active)}"

    # CHANGED: Collect affected rooms before updating so we can broadcast once per room at the end
    affected_rooms = Set.new

    # CHANGED: Use update_columns instead of update! to skip callbacks during batch job
    # This prevents multiple conflicting broadcasts while updates are in progress
    expired.find_each do |presentation|
      affected_rooms << presentation.room
      presentation.update_columns(active: false, updated_at: Time.current)
      Rails.logger.info("[RAILS::LOGGER::INFO] Deactivated expired: #{presentation.title} in #{presentation.room.name}")
    end

    current.find_each do |presentation|
      affected_rooms << presentation.room
      presentation.update_columns(active: true, updated_at: Time.current)
      Rails.logger.info "[RAILS::LOGGER::INFO] Activated current: #{presentation.title} in #{presentation.room.name}"
    end

    # CHANGED: Now that all updates are complete, broadcast once per affected room
    # Broadcasts to both: index page (presentations_table) AND individual room pages (room/:id)
    affected_rooms.each do |room|
      broadcast_room_presentations(room)  # Updates index page
      broadcast_individual_room_page(room)  # Updates room/:id page
      Rails.logger.info "[AUTO-UPDATE] Broadcasted updates for #{room.name}"
    end

    Rails.logger.info "[RAILS::LOGGER::INFO] Auto-update cycle completed"
  end

  def expired_presentations
    Presentation
      .where(active: true)
      .where("end_time <= ?", @current_time - 10.minutes)
  end

  def current_presentations
    Presentation
      .where(active: false)
      .where(
        "start_time <= ? AND end_time > ?",
        @current_time + 10.minutes, @current_time
      )
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

        Turbo::StreamsChannel.broadcast_replace_to(
          "room_#{room.id}_presentations",
          partial: "presentations/next_presentation",
          target: "next-presentation",
          locals: { next_presentation: next_presentation }
        )
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
