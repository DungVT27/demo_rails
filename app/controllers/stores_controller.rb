class StoresController < ApplicationController
  # Allow viewing stores without logging in
  before_action :authenticate_user!, except: [:index, :show]
  before_action :redirect_admin_to_dashboard

  def index
    # Search and filter active stores using Ransack
    @q = Store.active.ransack(params[:q])
    @stores = @q.result(distinct: true).order(name: :desc).page(params[:page]).per(::AppConstants::STORES_PER_PAGE_PUBLIC)
  end

  def show
    @store = Store.active.find(params[:id])
    # Pre-populate fields for new booking if logged in
    @booking = current_user.bookings.build(store: @store) if current_user.present?
  end

  private

  def redirect_admin_to_dashboard
    redirect_to admin_dashboard_path if current_user&.admin?
  end
end
