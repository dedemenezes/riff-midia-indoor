class StaticPresentationsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @static_presentation = StaticPresentation.find_by id: params[:id]
  end
end
