class RoomsController < ApplicationController
  skip_before_action :authenticate_user!
  def show
    @room = Room.includes(:media_files).find_by(id: params[:id])
    @media_file = @room.media_files.find_by(active: true)
    @media_file = MediaFile.new(title: "Próxima palestra em instantes") if @media_file.nil?
    # raise
  end
end
