# app.rb

require 'sinatra'
require 'json'
require 'set'
require_relative 'key_server'

key_server = KeyServer.new

Thread.new do
  loop do
    sleep 1
    key_server.cleanup
  end
end

# Route: /
get '/' do
  'OK'
end

# Route: generate keys
get '/keys' do
  keys = key_server.generate_keys(3)
  keys.join('<br/>')
end

# Displays the list of free keys
get '/free' do
  content_type :json
  key_server.free_keys.to_json
end

# Shows the status of all keys
get '/show' do
  content_type :json
  key_server.keys.to_json
end

# Route: Get key with given id
get '/key' do
  key = key_server.fetch_key
  if key.nil?
    status 404
    body 'No free keys found. Generate more keys.'
  else
    status 200
    body key
  end
end

# Route: Unblock key with given id
get '/key/unblock/:id' do |key|
  if !key_server.unblock_key(key)
    status 404
    "No key #{key} found"
  else
    status 200
    "Unblock successful for #{key}"
  end
end

# Route: Delete key with given id
get '/key/delete/:id' do |key|
  if !key_server.delete_key(key)
    status 404
    "No key #{key} found"
  else
    status 200
    "Delete successful for #{key}"
  end
end

# Route: Keep alive key with given id
get '/key/keep/:id' do |key|
  if !key_server.keep_alive_key(key)
    status 404
    "No key #{key} found"
  else
    status 200
    "Keep alive successful for #{key}"
  end
end
