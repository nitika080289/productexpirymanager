# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require_relative 'app/mailers/notification_mailer'
require_relative 'app/mailers/application_mailer'

Rails.application.load_tasks

task :send_notifications do
  #User.all.each do |user|
  # Product.find(user_id).where('expiry_date - sysdate <= :days').each do |product|
  NotificationMailer.notification_email('nitika.convegenius@gmail.com').deliver
  # end
end
