class StaticPresentationsController < ApplicationController
  def show
    @static_presentation = StaticPresentation.find_by id: params[:id]
  end
end
