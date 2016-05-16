# spec/key_server_spec.rb

require_relative 'spec_helper'

describe KeyServer do
  before :all do
    @key_server = KeyServer.new
  end

  describe '#new' do
    it 'should return a new KeyServer object' do
      expect(@key_server).to be_a KeyServer
    end

    it 'should not return nil' do
      expect(@key_server).not_to be_nil
    end
  end

  describe '#random_key' do
    it 'should return a key with default length' do
      key = @key_server.random_key
      expect(key.length).to eq(8)
    end
  end

  describe '#generate_keys' do
    it 'should return a keys array of given length' do
      keys = @key_server.generate_keys(3)
      expect(keys.size).to eq(3)
    end

    it 'should initialize timestamp of all keys to nil' do
      result = true
      @key_server.keys.each do |k, _v|
        result &= !@key_server.keys[k][:timestamp]
      end
      expect(result).to be_truthy
    end
  end

  describe '#fetch_key' do
    it 'should return a key if available' do
      @key_server.generate_keys(3)
      key = @key_server.fetch_key
      expect(key).not_to be_nil
    end

    it 'should return 404 if no key available' do
      @key_server.fetch_key until @key_server.free_keys.empty?
      key = @key_server.fetch_key
      expect(key).to be_nil
    end

    it 'should handle multiple parallel requests' do
      @key_server.generate_keys(3)
      threads = []
      keys = []
      threads << Thread.new { 5.times { keys << @key_server.fetch_key } }
      threads.map(&:join) # wait for all threads to finish
      expect(keys.count(nil)).to eq(2)
      expect(keys.reject(&:nil?).size).to eq(3)
    end
  end

  describe '#unblock_key' do
    it 'returns false if no key found' do
      expect(@key_server.unblock_key('samplekey')).to be_falsey
    end

    it 'unblocks a key if given key argument is valid' do
      @key_server.generate_keys(1)
      key = @key_server.fetch_key
      @key_server.unblock_key(key)
      expect(@key_server.free_keys).to have_key(key)
    end
  end

  describe '#delete_key' do
    it 'returns false if no key found' do
      expect(@key_server.delete_key('samplekey')).to be_falsey
    end

    it 'deletes a key if given key argument is valid' do
      @key_server.generate_keys(1)
      key = @key_server.fetch_key
      @key_server.delete_key(key)
      expect(@key_server.keys).not_to have_key(key)
      expect(@key_server.free_keys).not_to have_key(key)
      expect(@key_server.deleted_keys).to include(key)
    end
  end

  describe '#keep_alive_key' do
    it 'returns false if no key found' do
      expect(@key_server.keep_alive_key('samplekey')).to be_falsey
    end

    it 'returns false if key is older than 5 minutes' do
      @key_server.generate_keys(1)
      key = @key_server.fetch_key
      @key_server.keys[key][:timestamp] = Time.now.to_i - 301
      @key_server.cleanup
      expect(@key_server.keep_alive_key(key)).to be_falsey
    end

    it 'updates key timestamp to current time' do
      @key_server.generate_keys(1)
      key = @key_server.fetch_key
      @key_server.keys[key][:timestamp] = Time.now.to_i - 61
      @key_server.keep_alive_key(key)
      expect(@key_server.keys[key][:timestamp]).to eq(Time.now.to_i)
    end
  end

  describe '#expired' do
    it 'returns false if no key found' do
      expect(@key_server.expired?('samplekey', 60)).to be_falsey
    end

    it 'returns false if timestamp is nil' do
      @key_server.generate_keys(1)
      expect(@key_server.expired?(@key_server.free_keys[0], 60)).to be_falsey
    end

    it 'returns false if timestamp is within the given time limit' do
      @key_server.generate_keys(1)
      key = @key_server.fetch_key
      @key_server.keys[key][:timestamp] = Time.now.to_i - 1
      expect(@key_server.expired?(key, 60)).to be_falsey
    end

    it 'returns false if timestamp is past the given time limit' do
      @key_server.generate_keys(1)
      key = @key_server.fetch_key
      @key_server.keys[key][:timestamp] = Time.now.to_i - 61
      expect(@key_server.expired?(key, 60)).to be_truthy
    end
  end
end
