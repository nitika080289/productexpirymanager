class EmailNotifierJob < ApplicationJob
  queue_as :default
  def perform(*args)
    message = ''
    User.find_each do |user|
      Product.where('expiry_date < :date and user_id = :id',
                    id: user.id, date: 5.days.from_now).each do |product|
        message = message + product.name + ':' + "\t" +
                  product.expiry_date.to_s + "\n"
      end
      NotificationMailer.notification_email(user.name, user.email, message).deliver
      message = ''
      end
  end
end
