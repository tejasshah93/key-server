# Class KeyServer
class KeyServer
  attr_accessor :keys, :free_keys, :deleted_keys

  # Constructor
  def initialize
    @keys = {}
    @free_keys = {}
    @deleted_keys = Set.new
  end

  # Generates a random key
  def random_key
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    result = (0...8).map { o[rand(o.length)] }.join
    result
  end

  # Generates keys
  def generate_keys(length)
    while @free_keys.size < length
      key = random_key
      next if @free_keys.key?(key) || @deleted_keys.include?(key)

      @keys[key] = { 'timestamp' => nil }
      @free_keys[key] = true
    end
    @free_keys.keys
  end

  # Retrieves a free key if available else returns nil
  def fetch_key
    return nil if @free_keys.size.eql? 0
    key = @free_keys.shift[0]
    @keys[key][:timestamp] = Time.now.to_i
    key
  end

  # Unblocks the key with given id
  def unblock_key(key)
    return false unless @keys.key? key
    @keys[key][:timestamp] = nil
    @free_keys[key] = true
    true
  end

  # Deletes the key with given id
  def delete_key(key)
    return false unless @keys.key? key
    @keys.delete(key)
    @free_keys.delete(key)
    @deleted_keys.add key
    true
  end

  # Keeps alive the key with given id
  def keep_alive_key(key)
    return false unless @keys.key? key
    if expired?(key, 300)
      delete_key(key)
      return false
    end

    unless @keys[key][:timestamp].nil?
      @free_keys[key] = true if expired?(key, 60) && !@free_keys[key]
    end
    @keys[key][:timestamp] = Time.now.to_i
    true
  end

  # Checks if the key is expired w.r.t to the time limit passed as argument
  def expired?(key, time)
    return false if !@keys.key?(key) || @keys[key][:timestamp].nil?
    return true if (Time.now.to_i - @keys[key][:timestamp]) > time
    false
  end
end
