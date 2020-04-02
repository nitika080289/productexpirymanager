require_relative 'application_mailer'
class NotificationMailer < ApplicationMailer

  def notification_email
    @message = ''
    User.all.each do |user|
      Product.where('expiry_date > current_date - interval \'5\' day').each do |product|
        @message = @message + product.name + ':' + "\t" + product.expiry_date.to_s + "\n"
      end
      @name = user.name
      @email = user.email
      mail(to: @email, subject: 'Items expiring soon..!!')
    end
  end
end
