$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'

module Punch
  class << self
    private
    attr_accessor :data
    
    public
    
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
      project_data = data[project]
      return nil if !project_data or project_data.empty?
      
      time_data = project_data.last
      if time_data['out']
        'out'
      else
        'in'
      end
    end
    
    def out?(project)
      status(project) != 'in'
    end
    
    def in?(project)
      status(project) == 'in'
    end
    
    def in(project)
      return false if in?(project)
      data[project] ||= []
      data[project].push({'in' => Time.now})
      write
      true
    end
    
    def out(project)
      return false if out?(project)
      data[project].last['out'] = Time.now
      write
      true
    end
    
    def delete(project)
      return nil unless data.delete(project)
      write
      true
    end
    
    def list(project)
      data[project]
    end
    
    def total(project)
      return nil unless data[project]
      data[project].collect { |t|  ((t['out'] || Time.now) - t['in']).to_i }.inject(0) { |sum, t|  sum + t }
    end
  end
end
