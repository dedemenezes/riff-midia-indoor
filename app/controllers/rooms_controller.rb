class RoomsController < ApplicationController
  def show
    @room = Room.includes(:media_files).find_by(id: params[:id])
    @media_file = @room.media_files.find_by(active: true)
    # raise
  end
end
