# README

*About the Project*

This application helps keep a track of the products expiry date on your shelves. It also sends daily notifications on which products have expired/are going to expire soon. That way we can reduce food wastage.

*Tech Stack*

Ruby on Rails, React, Sidekiq with Redis

*Prerequisites for local setup*

Redis server up and running on your machine
Install necessary dependencies
Email server setup to deliver email notifications
Google client, redis server and smtp server details handy
Postgres db. Run migrations. Database name - productexpirymanager_development for local dev env
Install dependencies

*To run the application locally*

From the root directory of the project, run 'rails s'. Connect to localhost:3000 to access the application. You need to 
go through gmail authentication.
To run sidekiq, 'bundle exec sidekiq' from the root directory

*Functionality supported by the application*

1. Login using gmail auth
2. Add a new product
3. Delete exisiting product
4. Views the products along with the status i.e. Expired, Expiring or Safe to Use
