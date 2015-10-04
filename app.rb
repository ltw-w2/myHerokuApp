# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader'
require 'redis'

require_relative 'config/initializers/redis'

# Redis Settings
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
  last_access_at    = redis.lindex("HISTORY", 0)

  # 初回アクセス時の処理
  if last_access_at == nil then
    last_access_at = current_access_at
  end

  # Redis に最終アクセス時刻をキャッシュ
  redis.lpush("HISTORY", current_access_at)

  # ERB で view をテンプレート化
  erb :index, 
      :locals => {:last_access_at    => last_access_at, 
                  :current_access_at => current_access_at}
end


get '/login' do
  @title   = "Login Page"
  @message = "Hello, World!!"
  @errMessage = ""

  # GET Method の値によってエラーメッセージを振り分ける
  if params[:failed] == "1" then
    @errMessage = "Name is empty."
  elsif params[:failed] == "2" then
    @errMessage = "Password is empty."
  end

  erb :login
end


post '/dashboard' do
  @title   = "Dashboard"
  @message = "Sorry, this page is Under Construction..."

  # POSTされた値を取得
  name   = @params[:name]
  passwd = @params[:password]

  # 入力値チェック
  if name.empty? then
    redirect '/login?failed=1'
  elsif passwd.empty? then
    redirect '/login?failed=2'
  end

  # 簡易暗号化
  # 文字列(=passwd) とランダムな2文字(=salt) を使って DES暗号化
  salt = [rand(64), rand(64)].pack("C*").tr("\x00-\x3f","A-Za-z0-9./")
  cryptPasswd = passwd.crypt(salt)

  @debugMessage = {:name => name, :passwd => cryptPasswd}

  erb :dashboard
end


get '/history' do
  @title   = "Access Logs"
  @message = ""

  # 直近5件のアクセス履歴を表示
  @logs = Array.new
  5.times do |idx|
    @logs[idx] = redis.lindex("HISTORY", idx)
  end

  # 6件目移行を削除
  if redis.llen("HISTORY") > 5 then
    redis.ltrim("HISTORY", 0, 4)
  end

  erb :history
end
