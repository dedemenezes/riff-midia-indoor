class PresentationsController < ApplicationController
  def new
    @presentation = Presentation.new
  end

  def create
    @presentation = Presentation.new(presentation_params)
    if @presentation.save
      redirect_to room_path(@presentation.room), notice: "Image added to #{@presentation.room.name}"
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def presentation_params
    params.require(:presentation).permit(:room_id, :active, :image)
  end
end
