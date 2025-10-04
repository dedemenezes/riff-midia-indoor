class ImportPresentationsJob < ApplicationJob
  queue_as :default

  def perform
    warning = []

    begin
      # Step 1: Scrape and parse CSV
      presentations_data = scrape_and_parse

      # Step 2: Validate presentations
      validated_data = validate_presentations(presentations_data, warning)

      # Step 3: Check for warning
      if warning.any?
        broadcast_flash(:alert, "Imported with #{warning.count} warning(s): #{warning.join(', ')}")
        return
      end

      # Step 4: Import in transaction
      import_count = import_presentations(validated_data)

      # Broadcast success
      broadcast_flash(:notice, "Successfully imported #{import_count} presentations (deleted all previous presentations)")

    rescue => e
      broadcast_flash(:alert, "Import failed: #{e.message}")
      Rails.logger.error "[RAILS::LOGGER::ERROR] ImportPresentationsJob failed: #{e.message}"
    end
  end

  private

  def scrape_and_parse
    scraped_csv_path = Rails.root.join('tmp', 'scraped_presentations.csv')

    # Scrape and generate CSV
    PresentationScraperService.call

    # Parse the CSV
    presentations_data = []
    CSV.foreach(scraped_csv_path, headers: true, header_converters: :symbol) do |row|
      presentations_data << {
        title: row[:title],
        start_time: row[:start_time],
        end_time: row[:end_time],
        presenter_name: row[:presenter_name],
        category: row[:category],
        description: row[:description],
        room_id: row[:room_id]
      }
    end

    presentations_data
  end

  def validate_presentations(presentations_data, warning)
    validated_data = []
    rooms = Room.all

    presentations_data.each_with_index do |row, index|
      # Check if room exists
      room = rooms.find{ |room| room.name == row[:room_id] }

      if room.nil?
        room = Room.create!(name: row[:room_id])
        warning << "Row #{index + 1}: Room '#{row[:room_id]}' not found so WE CREATE '#{row[:room_id]}' room. Please, ensure it should exist."
      end

      # Check required fields
      if row[:title].blank? || row[:start_time].blank? || row[:end_time].blank?
        warning << "Row #{index + 1}: [ERROR] Missing required fields"
      end

      # Add room object to data
      row[:room] = room
      validated_data << row
    end

    validated_data
  end

  def import_presentations(validated_data)
    ActiveRecord::Base.transaction do
      Presentation.destroy_all

      validated_data.each do |data|
        Presentation.create!(
          title: data[:title],
          start_time: data[:start_time],
          end_time: data[:end_time],
          presenter_name: data[:presenter_name],
          category: data[:category],
          description: data[:description],
          room: data[:room]
        )
      end
    end

    Rails.logger.info "[RAILS::LOGGER::INFO] ImportPresentationsJob: Created #{validated_data.count} presentations"
    validated_data.count
  end

  def broadcast_flash(type, message)
    Turbo::StreamsChannel.broadcast_replace_to(
      "flash_messages",
      target: "flash",
      partial: "shared/flashes",
      locals: { type: type, message: message }
    )
  end
end
