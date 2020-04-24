class EmailNotifierJob < ApplicationJob
  queue_as :default
  def perform(*args)
    NotificationMailer.notification_email.deliver!
  end
end
