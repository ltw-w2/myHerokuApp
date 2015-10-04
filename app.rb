# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader'
require 'redis'

require_relative 'config/initializers/redis'
require_relative 'models/user'

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
    @errMessage = "認証に失敗しました（ユーザ名/パスワードが間違っています）。"
  elsif params[:failed] == "2" then
    @errMessage = "登録に失敗しました（そのユーザは既に登録されています）。"
  end

  erb :login
end


post '/session' do
  if User::authenticate(params[:name], params[:password]) then
    redirect '/dashboard'
  else
    redirect 'login?failed=1'
  end
end


post '/regist' do
  if User::hasUser(params[:name]) then
    redirect '/login?failed=2'
  else
    user = User.create(:name => params[:name])
    user.encryptPassword(params[:password])
    if user.save! then
      redirect '/dashboard'
    else
      redirect '/login?failed=2'
    end
  end
end


get '/dashboard' do
  @title   = "Dashboard"
  @message = "Sorry, this page is Under Construction..."
  
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
