class AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    @users_count = User.count
    @admin_users_count = User.where(admin: true).count
    @regular_users_count = User.where(admin: false).count
    @waiting_approval_count = User.waiting_for_approve.count
    @active_users_count = User.active.count
    @inactive_users_count = User.inactive.count
  end
end
