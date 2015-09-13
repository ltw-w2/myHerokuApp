# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader'
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

configure :production do
  # Redis設定
  set :REDIS_HOST     => ENV['REDIS_HOST']
  set :REDIS_PORT     => ENV['REDIS_PORT']
  set :REDIS_PASSWORD => ENV['REDIS_PASSWORD']
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
  # インスタンス変数
  @title   = "Index Page"
  @message = "Hello, World!!"

  # ローカル変数
  current_access_at = Time.now()
  last_access_at    = redis.get("LAST_ACCESS_AT")

  # 初回アクセス時の処理
  if last_access_at == nil then
    last_access_at = current_access_at
  end

  # Redis に最終アクセス時刻をキャッシュ
  redis.set("LAST_ACCESS_AT", last_access_at)

  # ERB で view をテンプレート化
  erb :index, 
      :locals => {:last_access_at    => last_access_at, 
                  :current_access_at => current_access_at}
end
