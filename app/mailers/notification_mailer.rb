require_relative 'application_mailer'
class NotificationMailer < ApplicationMailer
  default from:'nitika@wetransfer.com'
  layout  'mailer'

  def notification_email(email)
    mail(to: email, subject: 'Important notification regarding expired products,
      you might be using right now..!!')
  end
end
