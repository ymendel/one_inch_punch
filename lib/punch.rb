$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'punch/core_ext'
require 'punch/instance'

class Punch
  class << self
    private
    attr_writer :data
    
    def data
      load unless @data
      @data
    end
    
    
    public
    
    def load
      begin
        raw = File.read(File.expand_path('~/.punch.yml'))
        @data = YAML.load(raw) || {}
      rescue Errno::ENOENT
        @data = {}
      end
      
      true
    end
    
    def reset
      @data = nil
    end
    
    def write
      File.open(File.expand_path('~/.punch.yml'), 'w') do |file|
        file.puts data.to_yaml
      end
    end
    
    def status(project = nil)
      return data.keys.inject({}) { |hash, project|  hash.merge(project => status(project)) } unless project
      
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
    
    def in(project, options = {})
      return false if in?(project)
      data[project] ||= []
      time = time_from_options(options)
      data[project].push({'in' => time})
      log(project, "punch in @ #{time.strftime('%Y-%m-%dT%H:%M:%S%z')}")
      log(project, options[:message]) if options[:message]
      true
    end
    
    def out(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      project = args.first
      if project
        return false unless do_out_single(project, options)
      else
        return false unless data.keys.collect { |project|  do_out_single(project, options) }.any?
      end
      true
    end
    
    def delete(project)
      return nil unless data.delete(project)
      true
    end
    
    def list(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      project = args.first
      if project
        do_list_single(project, options)
      else
        data.keys.inject({}) { |hash, project|  hash.merge(project => do_list_single(project, options)) }
      end
    end
    
    def total(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      list_data = list(*args)
      if list_data.is_a?(Hash)
        list_data.inject({}) { |hash, (project, project_data)|  hash.merge(project => do_total_time(project_data, options)) }
      else
        return nil unless list_data
        do_total_time(list_data, options)
      end
    end
    
    def log(project, message)
      return false unless in?(project)
      project_data = data[project].last
      project_data['log'] ||= []
      time = Time.now
      project_data['log'].push "#{message} @ #{time.strftime('%Y-%m-%dT%H:%M:%S%z')}"
      true
    end
    
    
    private
    
    def do_out_single(project, options)
      return false if out?(project)
      time = time_from_options(options)
      log(project, options[:message]) if options[:message]
      log(project, "punch out @ #{time.strftime('%Y-%m-%dT%H:%M:%S%z')}")
      data[project].last['out'] = time
    end
    
    def do_list_single(project, options)
      return nil unless project_data = data[project]
      project_data = project_data.select { |t|  t['in']                > options[:after] }  if options[:after]
      project_data = project_data.select { |t|  (t['out'] || Time.now) < options[:before] } if options[:before]
      project_data
    end
    
    def do_total_time(list_data, options)
      total = list_data.collect { |t|  ((t['out'] || Time.now) - t['in']).to_i }.inject(0) { |sum, t|  sum + t }
      return total unless options[:format]
      total.elapsed_time
    end
    
    def time_from_options(options)
      options[:time] || options[:at] || Time.now
    end
  end
end
