class PresentationAutoUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    current_time = DateTime.new(2025,10,3, 11, 16)

    # deactivate presentations
    expired_presentations = Presentation
                            .where(active: true)
                            .where("end_time <= ?", current_time)

    expired_presentations.find_each do |presentation|
      presentation.update!(active: false)
      Rails.logger.info("Deactivated expired: #{presentation.title} in #{presentation.room.name}")

      # presentation.room.broadcast
    end

    # Activate presentations
    current_presentations = Presentation
                            .where(active: false)
                            .where(
                              "start_time <= ? AND end_time > ?",
                              current_time, current_time
                            )

    current_presentations.find_each do |presentation|
      presentation
        .room
        .presentations
        .where(active: true)
        .update_all(active: false)

      presentation.update!(active: true)
      Rails.logger.info "Activated current: #{presentation.title} in #{presentation.room.name}"
    end
    Rails.logger.info "Auto-update cycle completed"
  end
end
