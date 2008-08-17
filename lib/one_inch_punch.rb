$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

module Punch
  class << self
    def load
      begin
        raw = File.read(File.expand_path('~/.punch.yml'))
        @data = YAML.load(raw)
      rescue Errno::ENOENT
        return false
      end
      
      true
    end
    
    def reset
      @data = nil
    end
    
    def write
      File.open(File.expand_path('~/.punch.yml'), 'w') do |file|
        file.puts @data.to_yaml
      end
    end
    
    def status(project)
    end
  end
end
