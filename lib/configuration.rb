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
    end
    
    def reset
      @@config = nil
    end
    
  end
  
end
