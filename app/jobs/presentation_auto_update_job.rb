class PresentationAutoUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # @current_time = DateTime.new(2025,9,30, 17, 29)
    @current_time = Time.current

    Rails.logger.info "[RAILS::LOGGER::INFO] Auto-update cycle starting at #{@current_time}"

    # deactivate presentations
    expired_presentations.find_each do |presentation|
      presentation.update!(active: false)
      Rails.logger.info("[RAILS::LOGGER::INFO] Deactivated expired: #{presentation.title} in #{presentation.room.name}")
    end

    # Activate presentations
    current_presentations.find_each do |presentation|
      deactivate_room_active_presentations(presentation)

      presentation.update!(active: true)
      Rails.logger.info "[RAILS::LOGGER::INFO] Activated current: #{presentation.title} in #{presentation.room.name}"
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
        @current_time - 10.minutes, @current_time
      )
  end

  def deactivate_room_active_presentations(presentation)
    Rails.logger.info "[RAILS::LOGGER::INFO] Deactivating #{presentation.title} | Start: #{presentation.start_time} | End: #{presentation.end_time}"
    presentation
      .room
      .presentations
      .where(active: true)
      .update_all(active: false)
  end
end
