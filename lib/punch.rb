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
    
    def status(project = nil, options = {})
      if project.is_a?(Hash)
        options = project
        project = nil
      end
      
      unless project
        stats = {}
        projects.each { |project|  stats[project] = status(project, options) }
        if options[:short]
          stats.reject! { |k, v|  v == 'out' }
          stats = 'out' if stats.empty?
        end
        return stats
      end
      
      project_data = data[project]
      time_data = (project_data || []).last
      
      if time_data
        status = time_data['out'] ? 'out' : 'in'
      end
      
      status, time_data = check_child_status(project, status, time_data)
      
      return status unless options[:full]
      return status if status.nil?
      
      { :status => status, :time => time_data[status] }
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
      log(project, 'punch in', :time => time)
      log(project, options[:message], :time => time) if options[:message]
      true
    end
    
    def out(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      project = args.first
      if project
        return false unless do_out_single(project, options)
      else
        return false unless projects.collect { |project|  do_out_single(project, options) }.any?
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
        list_projects = child_projects(project) + [project]
      else
        list_projects = projects
      end
      
      if list_projects.length == 1
        do_list_single(list_projects.first, options)
      else
        list_projects.inject({}) { |hash, project|  hash.merge(project => do_list_single(project, options)) }
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
    
    def log(project, message, options = {})
      raise ArgumentError, "Message is not an optional argument" if message.is_a?(Hash)
      return false unless in?(project)
      project_data = data[project].last
      project_data['log'] ||= []
      time = time_from_options(options)
      project_data['log'].push "#{message} @ #{time.strftime('%Y-%m-%dT%H:%M:%S%z')}"
      true
    end
    
    
    private
    
    def do_out_single(project, options)
      return false if out?(project)
      project = in_child(project) || project
      time = time_from_options(options)
      log(project, options[:message], :time => time) if options[:message]
      log(project, 'punch out', :time => time)
      data[project].last['out'] = time
    end
    
    def do_list_single(project, options)
      return nil unless project_data = data[project]
      project_data = project_data.select { |t|  t['in']                > options[:after] }  if options[:after]
      project_data = project_data.select { |t|  (t['out'] || Time.now) < options[:before] } if options[:before]
      project_data
    end
    
    def do_total_time(list_data, options)
      return nil unless list_data
      total = list_data.collect { |t|  ((t['out'] || Time.now) - t['in']).to_i }.inject(0) { |sum, t|  sum + t }
      return total unless options[:format]
      total.elapsed_time
    end
    
    def time_from_options(options)
      options[:time] || options[:at] || Time.now
    end
    
    def projects
      data.keys
    end
    
    def child_projects(project)
      projects.select { |proj|  proj.match(/^#{Regexp.escape(project)}\//) } - [project]
    end
    
    def in_child(project)
      child_projects(project).detect { |proj|  status(proj) == 'in' }
    end
    
    def check_child_status(project, status, time_data)
      if status != 'in'
        in_child = in_child(project)
        if in_child
          status = 'in'
          time_data = data[in_child].last
        end
      end
      
      return status, time_data
    end
  end
end
