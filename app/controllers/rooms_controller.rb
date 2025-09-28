class RoomsController < ApplicationController
  skip_before_action :authenticate_user!
  def show
    @room = Room.includes(:presentations).find_by(id: params[:id])
    @presentation = @room.presentations.find_by(active: true)
    @presentation = Presentation.new(title: "Próxima palestra em instantes") if @presentation.nil?
    # raise
  end
end
