# -*- coding: utf-8 -*-
require 'redis-objects'
require 'dm-core'
require 'dm-redis-adapter'
require 'bcrypt'

DataMapper.setup(:default, {:adapter => "redis"})

class User
  include Redis::Objects
  include DataMapper::Resource

  property :id,            Serial
  property :name,          String
  property :password_hash, String
  property :password_salt, String

  def encryptPassword(password)
    self.password_salt = BCrypt::Engine.generate_salt()
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  # def hasUser(name)
  # end

  # def authenticate(name, password)
  # end
end

User.finalize

