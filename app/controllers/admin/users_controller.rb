class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :destroy ]

  def index
    # Exclude admins or allow listing all users, but filter by Ransack
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).order(name: :desc).page(params[:page]).per(::Constants::USERS_PER_PAGE_ADMIN)
  end

  def show
    @bookings = @user.bookings.includes(:store).order(booking_date: :desc)
  end

  def destroy
    if @user.admin?
      redirect_to admin_users_path, alert: I18n.t("messages.admin.users.delete_admin_error"), status: :see_other
      return
    end

    if @user.destroy
      redirect_to admin_users_path, success: I18n.t("messages.admin.users.single_delete_success"), status: :see_other
    else
      redirect_to admin_users_path, alert: I18n.t("messages.admin.users.delete_booking_error"), status: :see_other
    end
  end

  def bulk_destroy
    user_ids = params[:user_ids]
    if user_ids.blank?
      redirect_to admin_users_path, alert: I18n.t("messages.admin.users.no_selection_error"), status: :see_other
      return
    end

    users_to_delete = User.where(id: user_ids)
    success_count = 0
    error_message = nil

    ActiveRecord::Base.transaction do
      users_to_delete.each do |user|
        if user.admin?
          error_message = I18n.t("messages.admin.users.delete_admin_error")
          raise ActiveRecord::Rollback
        end

        if user.destroy
          success_count += 1
        else
          # Grab full error details if any, or default to general error
          error_message = user.errors.full_messages.to_sentence.presence || I18n.t("messages.admin.users.delete_booking_error")
          raise ActiveRecord::Rollback
        end
      end
    end

    if success_count == users_to_delete.size
      redirect_to admin_users_path, success: I18n.t("messages.admin.users.bulk_delete_success", count: success_count), status: :see_other
    else
      msg = "#{error_message}"
      redirect_to admin_users_path, alert: msg, status: :see_other
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
