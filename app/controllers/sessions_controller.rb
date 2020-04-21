class SessionsController < ApplicationController
  skip_before_action :require_user

  def create
    # Get access tokens from the google server
    access_token = request.env['omniauth.auth']
    @user = User.create_from_omniauth(access_token)
    cookies.encrypted[:current_user_id] = { value: @user.id, expires: Time.now + 7.days }
    flash[:message] = 'Successfully logged in'
    redirect_to root_path
  end

  def destroy
    cookies.encrypted[:current_user_id] = nil
    flash[:message] = "Successfully logged out "
    redirect_to root_path
  end
end
