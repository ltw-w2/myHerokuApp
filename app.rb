require 'sinatra'

configure :staging do
  use Rack::Auth::Basic do |username, password|
    username == ENV['STAGING_BASIC_AUTH_USERNAME'] && 
      password == ENV['STAGING_BASIC_AUTH_PASSWORD']
  end
end

get '/' do
  "Hello, World!!"
end
