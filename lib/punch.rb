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
    
    def status(project = nil)
      return data.inject({}) { |hash, (project, data)|  hash.merge(project => status(project)) } unless project
      
      project_data = data[project]
      return nil if !project_data or project_data.empty?
      
      time_data = project_data.last
      time_data['out'] ? 'out' : 'in'
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
    
    def out(project = nil)
      if project
        return false if out?(project)
        data[project].last['out'] = Time.now
      else
        changed = false
        data.each_key do |project|
          next if out?(project)
          data[project].last['out'] = Time.now
          changed = true
        end
        return false unless changed
      end
      write
      true
    end
    
    def delete(project)
      return nil unless data.delete(project)
      write
      true
    end
    
    def list(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      project = args.first
      if project
        return nil unless project_data = data[project]
        project_data = project_data.select { |t|  t['in']  > options[:after] }  if options[:after]
        project_data = project_data.select { |t|  t['out'] < options[:before] } if options[:before]
        project_data
      else
        list_data = data
        list_data.each_key do |project|
          list_data[project] = list_data[project].select { |t|  t['in']  > options[:after] }  if options[:after]
          list_data[project] = list_data[project].select { |t|  t['out'] < options[:before] } if options[:before]
        end
        list_data
      end
    end
    
    def total(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      project = args.first
      if project
        return nil unless data[project]
        list(project, options).collect { |t|  ((t['out'] || Time.now) - t['in']).to_i }.inject(0) { |sum, t|  sum + t }
      else
        data.inject({}) do |hash, (project, _)|
          hash.merge(project => list(project, options).collect { |t|  ((t['out'] || Time.now) - t['in']).to_i }.inject(0) { |sum, t|  sum + t })
        end
      end
    end
  end
end
