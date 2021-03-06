# encoding: UTF-8

class Hash

  # YAML suitable for configuration files
  #
  # returns sorted YAML if Ruby 1.8
  # returns insertion ordered YAML on Ruby 1.9+
  def to_conf
    unless RUBY_VERSION =~ /^1.8/
      # fix issue with strings that can end up in non UTF-8 encodings, like
      # ASCII-8BIT, force encoding so that they are not written to YAML as binary
      self.each_pair { |k,v| self[k] = ((v.is_a? String) ? v.force_encoding("UTF-8") : v)}

      # allow 1.9+ to_yaml to do insertion ordered conf files
      return to_yaml
    end

    opts = {}
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sorted_keys = keys
        sorted_keys = begin
          sorted_keys.sort
        rescue
          sorted_keys.sort_by {|k| k.to_s} rescue sorted_keys
        end

        sorted_keys.each do |k|
          map.add( k, fetch(k) )
        end
      end
    end
  end

  # active_support hash key functions
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end

  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end

  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        v.recursively_symbolize_keys!
      end
    end
    self
  end

  def stringify_keys!
    self.replace(self.stringify_keys)
  end

  def stringify_keys
    inject({}) do |options, (key, value)|
      options[(key.to_s rescue key) || key] = value
      options
    end
  end

  def recursively_stringify_keys!
    self.stringify_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_stringify_keys!
      elsif v.is_a? Array
        v.recursively_stringify_keys!
      end
    end
    self
  end

  # From ActiveSupport CoreExt
  #
  # Returns a deep copy of hash.
  #
  #   hash = { :a => { :b => 'b' } }
  #   dup  = hash.deep_clone
  #   dup[:a][:c] = 'c'
  #
  #   hash[:a][:c] #=> nil
  #   dup[:a][:c]  #=> "c"
  def deep_clone
    duplicate = self.dup
    duplicate.each_pair do |k,v|
      tv = duplicate[k]
      duplicate[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_clone : v
    end
    duplicate
  end

end
