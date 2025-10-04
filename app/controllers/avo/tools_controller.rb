require 'csv'
class Avo::ToolsController < Avo::ApplicationController
  def presentation_importer
    @page_title = "Presentation importer"
    add_breadcrumb "Presentation importer"
  end

  def create_presentations_importer
    ImportPresentationsJob.perform_later

    redirect_to presentation_importer_path,
                notice: "Import started! You'll be notified when it's complete."
  end
end
