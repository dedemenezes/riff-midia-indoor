module Avo
  module Resources
    class Presentation < Avo::BaseResource
      self.default_sort_column = :start_time
      self.default_sort_direction = :asc
      # self.includes = []
      # self.attachments = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
      # }

      def fields
        field :id, as: :id, sortable: false
        field :title, as: :text
        field :presenter_name, as: :text
        field :start_time, as: :date_time, sortable: true
        field :end_time, as: :date_time, sortable: true
        field :active, as: :boolean, sortable: true
        # field :room_id, as: :number
        field :image, as: :file
        field :room, as: :belongs_to
      end
    end
  end
end
