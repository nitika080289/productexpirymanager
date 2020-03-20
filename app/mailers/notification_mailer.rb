# frozen_string_literal: true

# Send notification email based on the email address and message from the db
class NotificationMailer < ApplicationMailer
  def notification_email(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(from: 'nitika@wetransfer.com', to: @email, subject:
        'Click open to view the items expiring soon in your shelves..!!!
         Time to take action.', message: @message)
  end
end
