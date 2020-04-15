class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  before_action :require_user

  helper_method :logged_in?, :current_user

  def logged_in?
    cookies.encrypted[:current_user_id].present?
  end

  def current_user
    if cookies.encrypted[:current_user_id].present?
      begin
        User.find(cookies.encrypted[:current_user_id])
      rescue
        nil
      end
    end
  end

  def require_user
    redirect_to root_path unless logged_in?
  end
end
