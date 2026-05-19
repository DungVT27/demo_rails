class Admin::StoresController < Admin::BaseController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  def index
    @q = Store.ransack(params[:q])
    @stores = @q.result(distinct: true).order(name: :desc).page(params[:page]).per(::AppConstants::STORES_PER_PAGE_ADMIN)
  end

  def show
  end

  def new
    @store = Store.new
  end

  def edit
  end

  def create
    @store = Store.new(store_params)

    if @store.save
      redirect_to admin_store_path(@store), success: I18n.t("app_messages.admin.stores.create_success", name: @store.name)
    else
      flash.now[:alert] = "Failed to create store. Please review the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @store.update(store_params)
      redirect_to admin_store_path(@store), success: I18n.t("app_messages.admin.stores.update_success", name: @store.name)
    else
      flash.now[:alert] = "Failed to update store. Please review the errors below."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @store.bookings.any?
      redirect_to admin_stores_path, alert: I18n.t("app_messages.admin.stores.delete_error"), status: :see_other
      return
    end

    if @store.destroy
      redirect_to admin_stores_path, success: I18n.t("app_messages.admin.stores.delete_success"), status: :see_other
    else
      redirect_to admin_stores_path, alert: I18n.t("app_messages.admin.stores.delete_error"), status: :see_other
    end
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :description, :address, :opening_time, :closing_time, :booking_fee, :status)
  end
end
