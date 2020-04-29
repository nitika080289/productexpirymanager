class User < ApplicationRecord
  include ActionController::Cookies
  validates :name, presence: true
  validates :email, presence: true

  def self.create_from_omniauth(auth, cookies)
    # Creates a new user only if it doesn't exist
    User.find_or_create_by(email: auth.info.email) do |user|
      user.name = auth.info.name
      # create cookie after user is made
      cookies.encrypted[:current_user_id] = { value: user.id, expires: 7.days.from_now }
    end
  end
end
