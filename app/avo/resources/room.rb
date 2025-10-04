class Avo::Resources::Room < Avo::BaseResource
  # self.visible_on_sidebar = false
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :visible, as: :boolean
    # field :presentations, as: :has_many
    field :presentations,
      as: :has_many,
      scope: -> { query.where("start_time >= ?", Time.current.to_date).order(start_time: :asc) }
  end
end
