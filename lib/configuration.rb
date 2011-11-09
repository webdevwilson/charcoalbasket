require 'yaml'

class Configuration
  
  class << self
    
    def [](name)
      get_config()[name]
    end
    
    def get_config
      @@config ||= load_file( File.join(File.dirname(__FILE__), '..', 'config.yaml') )
    end
    
    def load_file( file )
      @@config ||= YAML.load_file( file )
      @@config.deep_merge!( @@config['environment'][@@environment] ) if defined?(@@environment) && @@environment && @@config['environment'][@@environment]
      @@config
    end
    
    def environment
      @@environment
    end
    
    def environment=(env)
      reset
      @@environment = env
    end
    
    def reset
      @@config = nil
      @@environment = nil
    end
    
  end
  
end

class Hash

  # Merges self with another hash, recursively.
  # 
  # This code was lovingly stolen from some random gem:
  # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  # 
  # Thanks to whoever made it.
  def deep_merge(hash)
    target = dup
    
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      
      target[key] = hash[key]
    end
    
    target
  end


  # From: http://www.gemtacular.com/gemdocs/cerberus-0.2.2/doc/classes/Hash.html
  # File lib/cerberus/utils.rb, line 42
  def deep_merge!(second)
    second.each_pair do |k,v|
      if self[k].is_a?(Hash) and second[k].is_a?(Hash)
        self[k].deep_merge!(second[k])
      else
        self[k] = second[k]
      end
    end
  end
  
end

