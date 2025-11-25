class HomeController < ApplicationController
  def index
    if logged_in?
      @user = current_user
      if admin?
        redirect_to admin_dashboard_path
        nil
      end
    else
      redirect_to signup_path
    end
  end
end
