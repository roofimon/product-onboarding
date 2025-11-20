class ProfilesController < ApplicationController
  before_action :require_login
  before_action :set_user, only: [:show, :edit, :update, :reset_password, :update_password]

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully!"
    else
      flash.now[:alert] = "Please fix the errors below"
      render :edit, status: :unprocessable_entity
    end
  end

  def reset_password
  end

  def update_password
    current_password = params[:user][:current_password]
    
    if current_password.present? && @user.authenticate(current_password)
      if @user.update(password_params)
        redirect_to profile_path, notice: "Password updated successfully!"
      else
        flash.now[:alert] = "Please fix the errors below"
        render :reset_password, status: :unprocessable_entity
      end
    else
      @user.errors.add(:current_password, "is incorrect")
      flash.now[:alert] = "Current password is incorrect"
      render :reset_password, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:name, :surname, :email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end

