class NotificationMailer < ApplicationMailer
  def notification_email(name, email, message)
    @message = message
    @name = name
    mail(to: email, subject: 'Items expiring soon..!!')
  end
end
