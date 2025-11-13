class Admin::UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.all
    @total_count = User.count
    @waiting_count = User.waiting_for_approve.count
    @active_count = User.active.count
    @inactive_count = User.inactive.count
    
    if params[:status].present? && User.statuses.key?(params[:status])
      @users = @users.where(status: params[:status])
    end
    
    @users = @users.order(created_at: :desc)
  end
end
