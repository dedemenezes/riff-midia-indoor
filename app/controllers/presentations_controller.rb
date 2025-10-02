class PresentationsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action do
    I18n.locale = :'pt-BR'
  end
  def index
    now = Time.current

    # Check if preview mode
    if params[:preview_ids].present?
      @presentations_by_room = preview_presentations
    else
      @presentations_by_room = normal_presentations(now)
    end
  end

  private

  def preview_presentations
    preview_ids = params[:preview_ids].split(',').map(&:to_i)
    presentations = Presentation.includes(:room).where(id: preview_ids).order(:start_time)

    # Group by room, maintaining the order
    presentations.group_by(&:room).transform_values { |presos| presos.first(2) }
  end

  def normal_presentations(now)
    Room.includes(:presentations).map do |room|
      active = room.presentations.find do |p|
        p.start_time <= now && p.end_time >= now
      end

      upcoming = room.presentations
                    .where("start_time > ?", now)
                    .order(start_time: :asc)
                    .to_a

      presentations = []
      presentations << active if active
      presentations.concat(upcoming).uniq!

      [room, presentations.first(2)]
    end.to_h
  end

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
