require 'csv'
class Avo::ToolsController < Avo::ApplicationController
  def presentation_importer
    @page_title = "Presentation importer"
    add_breadcrumb "Presentation importer"
  end

  def create_presentations_importer
    create_presentation_importer = params.fetch(:create_presentation_importer, {})
    uploaded_file = create_presentation_importer.fetch(:csv, nil)

    unless uploaded_file
      redirect_to presentation_importer_path, alert: "Please select a CSV file"
      return
    end

    errors = []
    presentations_data = []

    # Step 1: Validate entire CSV first (before touching the database)
    begin
      CSV.foreach(uploaded_file.path, headers: true, header_converters: :symbol).with_index(2) do |row, line_number|
        # Check if room exists
        room = Room.find_by(name: row[:room_id])

        if room.nil?
          errors << "Line #{line_number}: Room '#{row[:room_id]}' not found"
          next
        end

        # Check required fields
        if row[:title].blank? || row[:start_time].blank? || row[:end_time].blank?
          errors << "Line #{line_number}: Missing required fields (title, start_time, or end_time)"
          next
        end

        # Store validated data for import
        presentations_data << {
          title: row[:title],
          start_time: row[:start_time],
          end_time: row[:end_time],
          presenter_name: row[:presenter_name],
          category: row[:category],
          description: row[:description],
          room: room
        }
      end
    rescue CSV::MalformedCSVError => e
      redirect_to presentation_importer_path, alert: "Invalid CSV file: #{e.message}"
      return
    end

    # Step 2: If there are validation errors, don't proceed
    if errors.any?
      flash[:alert] = "Import failed with #{errors.count} error(s):\n#{errors.join("\n")}"
      redirect_to presentation_importer_path
      return
    end

    # Step 3: Import in transaction (all-or-nothing)
    begin
      ActiveRecord::Base.transaction do
        Presentation.destroy_all

        presentations_data.each do |data|
          Presentation.create!(data)
        end
      end

      redirect_to presentation_importer_path,
                  notice: "Successfully imported #{presentations_data.count} presentations (deleted all previous presentations)"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to presentation_importer_path,
                  alert: "Import failed during save: #{e.message}. No changes were made."
    end
  end
end
