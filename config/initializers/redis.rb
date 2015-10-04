# -*- coding: utf-8 -*-

configure :development, :test do
  set :REDIS_HOST     => "127.0.0.1"
  set :REDIS_PORT     => "6379"
  set :REDIS_PASSWORD => nil
end

configure :staging do
  # BASIC認証
  use Rack::Auth::Basic do |username, password|
    username == ENV['STAGING_BASIC_AUTH_USERNAME'] && 
      password == ENV['STAGING_BASIC_AUTH_PASSWORD']
  end
  # Redis設定
  set :REDIS_HOST     => ENV['STAGING_REDIS_HOST']
  set :REDIS_PORT     => ENV['STAGING_REDIS_PORT']
  set :REDIS_PASSWORD => ENV['STAGING_REDIS_PASSWORD']
end

configure :production do
  # Redis設定
  set :REDIS_HOST     => ENV['REDIS_HOST']
  set :REDIS_PORT     => ENV['REDIS_PORT']
  set :REDIS_PASSWORD => ENV['REDIS_PASSWORD']
end

