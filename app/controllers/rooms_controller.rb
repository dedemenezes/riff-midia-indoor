class RoomsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @room = Room.includes(:presentations).find(params[:id])

    # only today's presentations
    todays_presentations = @room.presentations
                                .where(start_time: Time.zone.today.all_day)
                                .order(:start_time)

    # try active one first
    @presentation = todays_presentations.find_by(active: true)

    if @presentation
      # next one after the active
      active_index = todays_presentations.index(@presentation)
      @next_presentation = todays_presentations[active_index + 1]
    else
      # no active → grab the next one starting after now
      @presentation = todays_presentations.where("start_time > ?", Time.zone.now).first

      # if none upcoming today → mocked placeholder
      @presentation ||= Presentation.new(title: "Próxima palestra em instantes")

      # also grab the one right after (if there is one)
      if @presentation.persisted?
        pres_index = todays_presentations.index(@presentation)
        @next_presentation = todays_presentations[pres_index + 1]
      end
    end
  end
end
