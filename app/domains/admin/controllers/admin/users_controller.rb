class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [ :approve, :deactivate, :activate ]

  def index
    @users = User.where.not(id: current_user.id)
    @total_count = User.where.not(id: current_user.id).count
    @waiting_count = User.where.not(id: current_user.id).waiting_for_approve.count
    @active_count = User.where.not(id: current_user.id).active.count
    @inactive_count = User.where.not(id: current_user.id).inactive.count

    if params[:status].present? && User.statuses.key?(params[:status])
      @users = @users.where(status: params[:status])
    end

    @users = @users.order(created_at: :desc)
  end

  def approve
    if @user.waiting_for_approve?
      @user.update(status: :active)
      redirect_to admin_users_path(status: params[:status_filter] || params[:status]), notice: "#{@user.name} #{@user.surname} has been approved and is now active."
    else
      redirect_to admin_users_path(status: params[:status_filter] || params[:status]), alert: "User is not waiting for approval."
    end
  end

  def deactivate
    if @user.active?
      @user.update(status: :inactive)
      redirect_to admin_users_path(status: params[:status_filter] || params[:status]), notice: "#{@user.name} #{@user.surname} has been deactivated."
    else
      redirect_to admin_users_path(status: params[:status_filter] || params[:status]), alert: "User is not active."
    end
  end

  def activate
    if @user.inactive?
      @user.update(status: :active)
      redirect_to admin_users_path(status: params[:status_filter] || params[:status]), notice: "#{@user.name} #{@user.surname} has been activated."
    else
      redirect_to admin_users_path(status: params[:status_filter] || params[:status]), alert: "User is not inactive."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
