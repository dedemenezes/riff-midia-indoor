class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  before_action do
    I18n.locale = :'pt-BR'
  end

  def after_sign_in_path_for(resource)
    avo_path
  end
end
