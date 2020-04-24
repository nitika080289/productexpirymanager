class Product < ApplicationRecord
  belongs_to :user
  validates_presence_of :name, :quantity, :expiry_date, :user_id

  def list_expiring_products
    User.all.each do |user|
      products = list_expired_products(user.id, 7)
    end
  end

  def list_expired_products(user_id, _days)
    Product.find(user_id).where('expiry_date - sysdate <= :_days')
  end
end
