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
end
