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

  def self.hasUser(name)
    self.first(:name => name) != nil
  end

  def self.authenticate(name, password)
    user = self.first(:name => name)
    if user != nil then
      password_hash = BCrypt::Engine.hash_secret(password, user.password_salt)
      if user.password_hash == password_hash then
        return user
      end
      return nil
    end
  end
end

User.finalize

