module ApplicationHelper
  def presentation_badge(presentation)
    if presentation.active?
      content_tag(:span, "Em andamento", class: "badge rounded-pill text-bg-success")
    else
      content_tag(:span, "Próximo", class: "badge rounded-pill text-bg-primary")
    end
  end
end
