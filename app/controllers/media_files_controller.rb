class MediaFilesController < ApplicationController
  def new
    @media_file = MediaFile.new
  end

  def create
    @media_file = MediaFile.new(media_file_params)
    if @media_file.save
      redirect_to room_path(@media_file.room), notice: "Image added to #{@media_file.room.name}"
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def media_file_params
    params.require(:media_file).permit(:room_id, :active, :image)
  end
end
