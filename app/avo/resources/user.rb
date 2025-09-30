class Avo::Resources::User < Avo::BaseResource
  self.visible_on_sidebar = false
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :admin, as: :boolean
  end
end
