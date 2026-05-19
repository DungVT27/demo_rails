class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  private

  def verify_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: I18n.t("app_messages.access_denied")
    end
  end
end
