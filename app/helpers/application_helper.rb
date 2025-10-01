module ApplicationHelper
  def presentation_badge(presentation)
    if presentation.active?
      content_tag(
        :span,
        "Em andamento",
        class: "badge rounded-pill",
        style: "font-size:18px;background-color: rgb(220, 252, 231); color: rgb(22, 101, 52);"
      )
    else
      content_tag(
        :span,
        "Próximo",
        class: "badge rounded-pill",
        style: "font-size:18px;color: rgb(30, 64, 175);background-color: rgb(219, 234, 254);"
      )
    end
  end
end
