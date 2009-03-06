require File.dirname(__FILE__) + '/spec_helper.rb'

describe Punch, 'instance' do
  before do
    @project = 'proj'
    @punch = Punch.new(@project)
  end
  
  describe 'when initialized' do
    it 'should accept a project' do
      lambda { Punch.new(@project) }.should.not.raise(ArgumentError)
    end
    
    it 'should require a project' do
      lambda { Punch.new }.should.raise(ArgumentError)
    end
    
    it 'should save the project for later use' do
      Punch.new(@project).project.should == @project
    end
  end
  
  it 'should give project status' do
    @punch.should.respond_to(:status)
  end
  
  describe 'giving project status' do
    before do
      @status = 'status val'
      Punch.stub!(:status).and_return(@status)
    end
    
    it 'should accept options' do
      lambda { @punch.status(:full => true) }.should.not.raise(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.status }.should.not.raise(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:status)
      @punch.status
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:status) do |proj, _|
        proj.should == @project
      end
      @punch.status
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :full => true }
      Punch.should.receive(:status) do |_, opts|
        opts.should == options
      end
      @punch.status(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.should.receive(:status) do |_, opts|
        opts.should == {}
      end
      @punch.status
    end
    
    it 'should return the value returned by the class method' do
      @punch.status.should == @status
    end
  end
  
  it 'should indicate whether the project is punched out' do
    @punch.should.respond_to(:out?)
  end
  
  describe 'indicating whether the project is punched out' do
    before do
      @out = 'out val'
      Punch.stub!(:out?).and_return(@out)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:out?)
      @punch.out?
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:out?).with(@project)
      @punch.out?
    end
    
    it 'should return the value returned by the class method' do
      @punch.out?.should == @out
    end
  end
  
  it 'should indicate whether the project is punched in' do
    @punch.should.respond_to(:in?)
  end
  
  describe 'indicating whether the project is punched in' do
    before do
      @in = 'in val'
      Punch.stub!(:in?).and_return(@in)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:in?)
      @punch.in?
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:in?).with(@project)
      @punch.in?
    end
    
    it 'should return the value returned by the class method' do
      @punch.in?.should == @in
    end
  end
  
  it 'should punch the project in' do
    @punch.should.respond_to(:in)
  end
  
  describe 'punching the project in' do
    before do
      @in = 'in val'
      Punch.stub!(:in).and_return(@in)
    end
    
    it 'should accept options' do
      lambda { @punch.in(:time => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.in }.should.not.raise(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:in)
      @punch.in
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:in) do |proj, _|
        proj.should == @project
      end
      @punch.in
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.should.receive(:in) do |_, opts|
        opts.should == options
      end
      @punch.in(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.should.receive(:in) do |_, opts|
        opts.should == {}
      end
      @punch.in
    end
    
    it 'should return the value returned by the class method' do
      @punch.in.should == @in
    end
  end
  
  it 'should punch the project out' do
    @punch.should.respond_to(:out)
  end
  
  describe 'punching the project out' do
    before do
      @out = 'out val'
      Punch.stub!(:out).and_return(@out)
    end
    
    it 'should accept options' do
      lambda { @punch.out(:time => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.out }.should.not.raise(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:out)
      @punch.out
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:out) do |proj, _|
        proj.should == @project
      end
      @punch.out
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.should.receive(:out) do |_, opts|
        opts.should == options
      end
      @punch.out(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.should.receive(:out) do |_, opts|
        opts.should == {}
      end
      @punch.out
    end
    
    it 'should return the value returned by the class method' do
      @punch.out.should == @out
    end
  end
  
  it 'should list the project data' do
    @punch.should.respond_to(:list)
  end
  
  describe 'listing the project data' do
    before do
      @list = 'list val'
      Punch.stub!(:list).and_return(@list)
    end
    
    it 'should accept options' do
      lambda { @punch.list(:time => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.list }.should.not.raise(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:list)
      @punch.list
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:list) do |proj, _|
        proj.should == @project
      end
      @punch.list
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.should.receive(:list) do |_, opts|
        opts.should == options
      end
      @punch.list(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.should.receive(:list) do |_, opts|
        opts.should == {}
      end
      @punch.list
    end
    
    it 'should return the value returned by the class method' do
      @punch.list.should == @list
    end
  end
  
  it 'should get the project total' do
    @punch.should.respond_to(:total)
  end
  
  describe 'getting the project total' do
    before do
      @total = 'total val'
      Punch.stub!(:total).and_return(@total)
    end
    
    it 'should accept options' do
      lambda { @punch.total(:time => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.total }.should.not.raise(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:total)
      @punch.total
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:total) do |proj, _|
        proj.should == @project
      end
      @punch.total
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.should.receive(:total) do |_, opts|
        opts.should == options
      end
      @punch.total(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.should.receive(:total) do |_, opts|
        opts.should == {}
      end
      @punch.total
    end
    
    it 'should return the value returned by the class method' do
      @punch.total.should == @total
    end
  end
  
  it 'should log information about the project' do
    @punch.should.respond_to(:log)
  end
  
  describe 'logging information about the project' do
    before do
      @log = 'log val'
      @message = 'some log message'
      Punch.stub!(:log).and_return(@log)
    end
    
    it 'should accept a log message' do
      lambda { @punch.log(@message) }.should.not.raise(ArgumentError)
    end
    
    it 'should require a log message' do
      lambda { @punch.log }.should.raise(ArgumentError)
    end
    
    it 'should accept options' do
      lambda { @punch.log(@message, :time => Time.now) }.should.not.raise(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.should.receive(:log)
      @punch.log(@message)
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.should.receive(:log) do |proj, _, _|
        proj.should == @project
      end
      @punch.log(@message)
    end
    
    it 'should pass the message when delegating to the class' do
      Punch.should.receive(:log) do |_, msg, _|
        msg.should == @message
      end
      @punch.log(@message)
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.should.receive(:log) do |_, _, opts|
        opts.should == options
      end
      @punch.log(@message, options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.should.receive(:log) do |_, _, opts|
        opts.should == {}
      end
      @punch.log(@message)
    end
    
    it 'should return the value returned by the class method' do
      @punch.log(@message).should == @log
    end
  end
  
  it 'should return child projects' do
    @punch.should.respond_to(:child_projects)
  end
  
  describe 'returning child projects' do
    before do
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      
      @projects = {}
      @projects['parent'] = 'daddy'
      @projects['child']  = @projects['parent'] + '/sugar'
      @projects['kid']    = @projects['parent'] + '/object'
      
      @data = { @projects['parent'] => [], @projects['child'] => [], @projects['kid'] => [] }
      Punch.data = @data
    end
    
    it 'should return instances for each child project' do
      children = Punch.new(@projects['parent']).child_projects
      children.size.should == 2
      children.collect { |c|  c.class }.should == [Punch, Punch]
      children.collect { |c|  c.project }.sort.should == @projects.values_at('child', 'kid').sort
    end
    
    it "should provide 'children' as an alias" do
      children = Punch.new(@projects['parent']).children
      children.size.should == 2
      children.collect { |c|  c.class }.should == [Punch, Punch]
      children.collect { |c|  c.project }.sort.should == @projects.values_at('child', 'kid').sort
    end
    
    it 'should return an empty array if the project has no child projects' do
      @punch.child_projects.should == []
    end
  end
end
