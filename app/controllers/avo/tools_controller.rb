require 'csv'
class Avo::ToolsController < Avo::ApplicationController
  def presentation_importer
    @page_title = "Presentation importer"
    add_breadcrumb "Presentation importer"
  end

  def create_presentations_importer
    errors = []
    presentations_data = []

    # Step 1: Check if scraped CSV exists, otherwise scrape now
    scraped_csv_path = Rails.root.join('tmp', 'scraped_presentations.csv')

    begin
      # unless File.exist?(scraped_csv_path)
        # Scrape and generate CSV
        PresentationScraperService.call
      # end

      # Parse the scraped CSV
      presentations_data = parse_csv_file(scraped_csv_path, errors)
    rescue => exception
      redirect_to presentation_importer_path, alert: "Failed to process data: #{exception.message}"
      return
    end

    # Step 2: Validate all presentations
    presentations_data.each_with_index do |row, index|
      # line_number = index + 2 # Account for header row

      # Check if room exists
      room = Room.find_by(name: row[:room_id])

      if room.nil?
        errors << "Line #{index + 1}: Room '#{row[:room_id]}' not found"
        next
      end

      # Check required fields
      if row[:title].blank? || row[:start_time].blank? || row[:end_time].blank?
        errors << "Line #{index + 1}: Missing required fields (title, start_time, or end_time)"
        next
      end

      # Add room object to data for later use
      row[:room] = room
    end

    # Step 3: If there are validation errors, don't proceed
    if errors.any?
      flash[:alert] = "Import failed with #{errors.count} error(s):\n#{errors.join("\n")}"
      redirect_to presentation_importer_path
      return
    end

    # Step 4: Import in transaction (all-or-nothing)
    begin
      ActiveRecord::Base.transaction do
        Presentation.destroy_all
        # binding.b
        presentations_data.each do |data|
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

      redirect_to presentation_importer_path,
                  notice: "Successfully imported #{presentations_data.count} presentations (deleted all previous presentations)"
      Rails.logger.info("[RAILS::LOGGER::INFO] Created new presentation")
    rescue ActiveRecord::RecordInvalid => e
      redirect_to presentation_importer_path,
                  alert: "Import failed during save: #{e.message}. No changes were made.",
                  status: :unprocessable_entity
      Rails.logger.info("[RAILS::LOGGER::INFO] COULD NOT create new presentation")
    end
  end

  private

  def parse_csv_file(csv_path, errors)
    presentations_data = []

    CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|
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
  rescue CSV::MalformedCSVError => e
    raise "Invalid CSV file: #{e.message}"
  end
end
