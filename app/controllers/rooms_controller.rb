class RoomsController < ApplicationController
  skip_before_action :authenticate_user!
  def show
    @room = Room.includes(:media_files).find_by(id: params[:id])
    @media_file = @room.media_files.find_by(active: true)
    # raise
  end
end
