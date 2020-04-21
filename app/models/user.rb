class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true

  def self.create_from_omniauth(auth)
    # Creates a new user only if it doesn't exist
    where(email: auth.info.email).first_or_initialize do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.save!
      #create cookie after user is made
    end
  end
end
