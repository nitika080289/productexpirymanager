class Product < ApplicationRecord
  belongs_to :user
  validates_presence_of :name, :quantity, :expiry_date, :user_id

end
