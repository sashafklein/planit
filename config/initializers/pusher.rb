require 'pusher'

Pusher.url = "http://#{Env.pusher_app_key}:#{Env.pusher_secret_key}@api.pusherapp.com/apps/#{Env.pusher_app_id}"
Pusher.logger = Rails.logger