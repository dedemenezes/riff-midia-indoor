class Avo::Actions::GeneratePreviewLink < Avo::BaseAction
  self.name = "Generate Preview Link"
  self.standalone = false

  def handle(query:, fields:, current_user:, resource:, **args)
    preview_ids = query.pluck(:id).join(',')
    preview_url = "/presentations?preview_ids=#{preview_ids}"

    succeed "Preview URL: #{preview_url}"
    redirect_to Rails.application.routes.url_helpers.root_path(preview_ids: preview_ids)
  end
end
