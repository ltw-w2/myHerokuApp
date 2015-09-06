# -*- coding: utf-8 -*-
require 'sinatra'
require 'redis'

configure :staging do
  use Rack::Auth::Basic do |username, password|
    username == ENV['STAGING_BASIC_AUTH_USERNAME'] && 
      password == ENV['STAGING_BASIC_AUTH_PASSWORD']
  end
end

redis = Redis.new(host:"127.0.0.1", port:"6379")

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
