require 'bundler'
Bundler.require

require 'securerandom'

require './app.rb'
run Sinatra::Application

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "restaurant"
)

run Restaurant