module Avo
  module Resources
    class Presentation < Avo::BaseResource
      # self.includes = []
      # self.attachments = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
      # }

      def fields
        field :id, as: :id
        field :title, as: :text
        field :start_time, as: :date_time
        field :end_time, as: :date_time
        field :active, as: :boolean
        # field :room_id, as: :number
        field :image, as: :file
        field :room, as: :belongs_to
      end
    end
  end
end
