class SessionsController < ApplicationController
  skip_before_action :require_user

  def create
    # Get access tokens from the google server
    access_token = request.env["omniauth.auth"]
    User.create_from_omniauth(access_token)
    redirect_to root_path
  end

  def destroy
    cookies.encrypted[:current_user_id] = nil

    redirect_to root_path
  end
end
