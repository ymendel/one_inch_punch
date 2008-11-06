class Punch
  attr_reader :project
  
  def initialize(project)
    @project = project
  end
  
  def status
    self.class.status(project)
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
  
  def list(options = {})
    self.class.list(project, options)
  end
end
