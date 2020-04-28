class EmailNotifierJob < ApplicationJob
  queue_as :default
  def perform(*args)
    message = ''
    User.all.each do |user|
      Product.where('expiry_date - interval \'5\' day < current_date and
        user_id = :id', id: user.id).each do |product|
        message = message + product.name + ':' + "\t" +
            product.expiry_date.to_s + "\n"
      end
      NotificationMailer.notification_email(user.name, user.email, message).deliver
      message = ''
      end
  end
end
