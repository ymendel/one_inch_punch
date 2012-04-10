class Punch
  attr_reader :project
  
  def initialize(project)
    @project = project
  end
  
  def status(options = {})
    self.class.status(project, options)
  end
  
  def out?
    self.class.out?(project)
  end
  
  def in?
    self.class.in?(project)
  end
  
  def in(options = {})
    self.class.in(project, options)
  end
  
  def out(options = {})
    self.class.out(project, options)
  end

  def entry(options = {})
    self.class.entry(project, options)
  end
  alias_method :clock, :entry

  def list(options = {})
    self.class.list(project, options)
  end
  
  def total(options = {})
    self.class.total(project, options)
  end
  
  def log(message, options = {})
    self.class.log(project, message, options)
  end
  
  def summary(options = {})
    self.class.summary(project, options)
  end
  
  def age(options = {})
    self.class.age(project, options)
  end
  
  def ==(other)
    project == other.project
  end
  
  def child_projects
    Punch.send(:child_projects, project).collect { |proj|  Punch.new(proj) }
  end
  alias_method :children, :child_projects
end
