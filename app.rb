# app.rb

require 'sinatra'
require 'json'
require 'set'
require_relative 'key_server'

# Class AppKeyServer
class AppKeyServer < Sinatra::Base
  configure do
    set :key_server, KeyServer.new
  end

  # Route: /
  get '/' do
    'OK'
  end

  # Route: generate keys
  get '/keys' do
    keys = settings.key_server.generate_keys(3)
    keys.join('<br/>')
  end

  # Displays the list of free keys
  get '/free' do
    content_type :json
    settings.key_server.free_keys.to_json
  end

  # Shows the status of all keys
  get '/show' do
    content_type :json
    settings.key_server.keys.to_json
  end

  # Route: Get key with given id
  get '/key' do
    key = settings.key_server.fetch_key
    if key.nil?
      status 404
      body 'No free keys found. Generate more keys.'
    else
      key
    end
  end

  # Route: Unblock key with given id
  get '/key/unblock/:id' do |key|
    result = settings.key_server.unblock_key(key)
    if result
      status 200
      "Unblock successful for #{key}"
    else
      "No key #{key} found"
    end
  end

  # Route: Delete key with given id
  get '/key/delete/:id' do |key|
    result = settings.key_server.delete_key(key)
    if result
      status 200
      "Delete successful for #{key}"
    else
      "No key #{key} found"
    end
  end

  # Route: Keep alive key with given id
  get '/key/keep/:id' do |key|
    result = settings.key_server.keep_alive_key(key)
    if result
      status 200
      "Keep alive successful for #{key}"
    else
      "No key #{key} found"
    end
  end
end
