require 'sidekiq-scheduler'

class EmailNotificationWorker
  include Sidekiq::Worker
  def perform
    NotificationMailer.notification_email.deliver
  end

end
