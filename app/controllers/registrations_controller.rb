class RegistrationsController < ApplicationController
  def new
    if current_user
      redirect_to registration_completed_path
      return
    end
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to registration_completed_path, notice: "Account created successfully! Welcome, #{@user.name}!"
    else
      flash.now[:alert] = "Please fix the errors below"
      render :new, status: :unprocessable_entity
    end
  end

  def completed
    redirect_to root_path unless logged_in?
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :email, :password, :password_confirmation)
  end
end
