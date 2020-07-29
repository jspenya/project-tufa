class UsersController < ApplicationController
  # before_action :check_for_tfa

  def verify_enabled user_id=params[:user_id] || current_user.id
    user=User.find user_id
    user.otp_module_enabled!
    user.save!
    redirect_to users_path
  end

  def verify_disabled user_id=params[:user_id] || current_user.id
    user=User.find user_id
    user.otp_module_disabled!
    user.save!
    redirect_to users_path
  end 
  
  # def disable_otp user_id=params[:user_id] || current_user.id
  #   user = User.find user_id
  #   user.otp_required_for_login = false
  #   user.save!
  #   redirect_to users_path
  # end

  # def allow_tfa user_id=params[:user_id] || current_user.id
  #   user = User.find user_id
  #   user.admin_allow_tfa = true
  #   user.save!
  #   redirect_to users_path
  # end

  # def deny_tfa user_id=params[:user_id] || current_user.id
  #   user = User.find user_id
  #   user.admin_allow_tfa = false
  #   user.save!
  #   redirect_to users_path
  # end


  # def check_for_tfa
  #   if ! session[:otp_code]
  #     redirect_to two_factors_new_path
  #   end
  # end


  def index
    @users = User.all
    if Rails.env.production?
      @country = request.location.country
      @city = request.location.city
      @coordinates = request.location.coordinates
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])

    # if @user.update(user_params)
    #   redirect_to users_path
    # else
    #   render 'edit'
    # end
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to users_path
    else
      render 'edit'
    end
  end

  def create
    session[:otp_code] = '1234'
    @user = User.new(user_params)

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.save
      redirect_to users_path
    else
      render 'new'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password, :admin)
  end
end