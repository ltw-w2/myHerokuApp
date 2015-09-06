# -*- coding: utf-8 -*-
require 'sinatra'
require 'redis'

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


# Redis
if settings.REDIS_PASSWORD != nil then
  redis = Redis.new(:host => settings.REDIS_HOST,
                    :port => settings.REDIS_PORT,
                    :password => settings.REDIS_PASSWORD)
else
  redis = Redis.new(:host => settings.REDIS_HOST,
                    :port => settings.REDIS_PORT)
end


get '/' do
  # Redis に最終アクセス時刻をキャッシュ
  last_access_at = nil
  last_access_at = redis.get("LAST_ACCESS_AT")
  if last_access_at == nil then
    last_access_at = Time.now
  end
  redis.set("LAST_ACCESS_AT", Time.now)

  # 画面表示
  "Hello, World!! <br/>" +
    "Last access at: " + last_access_at.to_s + "<br/>" +
    "Current access at :" + Time.now.to_s + "<br/>"
end
