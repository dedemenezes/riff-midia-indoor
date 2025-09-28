class RoomsController < ApplicationController
  skip_before_action :authenticate_user!
  def show
    @room = Room.includes(:presentations).find_by(id: params[:id])
    sorted_presentations = @room.presentations.order(start_time: :asc)
    @presentation = sorted_presentations.find_by(active: true)
    @presentation = Presentation.new(title: "Próxima palestra em instantes") if @presentation.nil?
    active_presentation_index = sorted_presentations.index(@presentation)
    if active_presentation_index
      @next_presentation = sorted_presentations[active_presentation_index + 1]
    end
    # raise
  end
end
