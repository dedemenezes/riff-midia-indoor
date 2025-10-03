class CleanupOldPresentationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    deleted_count = Presentation.where("end_time < ?", Time.current).delete_all
    Rails.logger.info "[RAILS::LOGGER::INFO] CleanupOldPresentationsJob: Deleted #{deleted_count} finished presentations"
    deleted_count
  end
end
