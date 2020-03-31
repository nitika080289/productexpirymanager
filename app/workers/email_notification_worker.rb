class EmailNotificationWorker
  sidekiq_options retry: false

  include Sidekiq::Worker

end
