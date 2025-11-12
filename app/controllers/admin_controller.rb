class AdminController < ApplicationController
  before_action :require_admin

  def dashboard
    @users_count = User.count
    @admin_users_count = User.where(admin: true).count
    @regular_users_count = User.where(admin: false).count
    @recent_users = User.order(created_at: :desc).limit(5)
  end
end