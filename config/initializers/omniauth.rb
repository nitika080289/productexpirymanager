Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV.fetch('GOOGLE_CLIENT_ID'), ENV.fetch('GOOGLE_CLIENT_SECRET'),
           scope: %w[email https://www.googleapis.com/auth/gmail.modify],
           access_type: 'offline'
end
