module Avo
  module Resources
    class Presentation < Avo::BaseResource
      self.default_sort_column = :start_time
      self.default_sort_direction = :asc
      self.index_query = -> { query.where("start_time >= ?", Date.current) }

      # self.includes = []
      # self.attachments = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
      # }

      def fields
        field :room, as: :belongs_to
        field :active, as: :boolean, sortable: true
        field :start_time, as: :date_time, sortable: true
        field :end_time, as: :date_time, sortable: true
        field :title, as: :text
        field :presenter_name, as: :text
        field :category, as: :select, options: ::Presentation::CATEGORIES.map { |c| [c, c] }.to_h, sortable: true
        field :description, as: :text, hide_on: %i[index]
        # field :room_id, as: :number
        field :image, as: :file
        field :id, as: :id, sortable: false
      end

      def actions
        action Avo::Actions::GeneratePreviewLink
      end
    end
  end
end
