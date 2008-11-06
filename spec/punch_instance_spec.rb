require File.dirname(__FILE__) + '/spec_helper.rb'

describe Punch, 'instance' do
  before :each do
    @project = 'proj'
    @punch = Punch.new(@project)
  end
  
  describe 'when initialized' do
    it 'should accept a project' do
      lambda { Punch.new(@project) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a project' do
      lambda { Punch.new }.should raise_error(ArgumentError)
    end
    
    it 'should save the project for later use' do
      Punch.new(@project).project.should == @project
    end
  end
  
  it 'should give project status' do
    @punch.should respond_to(:status)
  end
  
  describe 'giving project status' do
    before :each do
      @status = 'status val'
      Punch.stubs(:status).returns(@status)
    end
    
    it 'should delegate to the class' do
      Punch.expects(:status)
      @punch.status
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.expects(:status).with(@project)
      @punch.status
    end
    
    it 'should return the value returned by the class method' do
      @punch.status.should == @status
    end
  end
  
  it 'should indicate whether the project is punched out' do
    @punch.should respond_to(:out?)
  end
  
  describe 'indicating whether the project is punched out' do
    before :each do
      @out = 'out val'
      Punch.stubs(:out?).returns(@out)
    end
    
    it 'should delegate to the class' do
      Punch.expects(:out?)
      @punch.out?
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.expects(:out?).with(@project)
      @punch.out?
    end
    
    it 'should return the value returned by the class method' do
      @punch.out?.should == @out
    end
  end
  
  it 'should indicate whether the project is punched in' do
    @punch.should respond_to(:in?)
  end
  
  describe 'indicating whether the project is punched in' do
    before :each do
      @in = 'in val'
      Punch.stubs(:in?).returns(@in)
    end
    
    it 'should delegate to the class' do
      Punch.expects(:in?)
      @punch.in?
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.expects(:in?).with(@project)
      @punch.in?
    end
    
    it 'should return the value returned by the class method' do
      @punch.in?.should == @in
    end
  end
  
  it 'should punch the project in' do
    @punch.should respond_to(:in)
  end
  
  describe 'punching the project in' do
    before :each do
      @in = 'in val'
      Punch.stubs(:in).returns(@in)
    end
    
    it 'should accept options' do
      lambda { @punch.in(:time => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.in }.should_not raise_error(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.expects(:in)
      @punch.in
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.expects(:in).with(@project, anything)
      @punch.in
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.expects(:in).with(anything, options)
      @punch.in(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.expects(:in).with(anything, {})
      @punch.in
    end
    
    it 'should return the value returned by the class method' do
      @punch.in.should == @in
    end
  end
  
  it 'should punch the project out' do
    @punch.should respond_to(:out)
  end
  
  describe 'punching the project out' do
    before :each do
      @out = 'out val'
      Punch.stubs(:out).returns(@out)
    end
    
    it 'should accept options' do
      lambda { @punch.out(:time => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.out }.should_not raise_error(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.expects(:out)
      @punch.out
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.expects(:out).with(@project, anything)
      @punch.out
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.expects(:out).with(anything, options)
      @punch.out(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.expects(:out).with(anything, {})
      @punch.out
    end
    
    it 'should return the value returned by the class method' do
      @punch.out.should == @out
    end
  end
  
  it 'should list the project data' do
    @punch.should respond_to(:list)
  end
  
  describe 'listing the project data' do
    before :each do
      @list = 'list val'
      Punch.stubs(:list).returns(@list)
    end
    
    it 'should accept options' do
      lambda { @punch.list(:time => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require options' do
      lambda { @punch.list }.should_not raise_error(ArgumentError)
    end
    
    it 'should delegate to the class' do
      Punch.expects(:list)
      @punch.list
    end
    
    it 'should pass the project when delegating to the class' do
      Punch.expects(:list).with(@project, anything)
      @punch.list
    end
    
    it 'should pass the options when delegating to the class' do
      options = { :time => Time.now }
      Punch.expects(:list).with(anything, options)
      @punch.list(options)
    end
    
    it 'should pass an empty hash if no options given' do
      Punch.expects(:list).with(anything, {})
      @punch.list
    end
    
    it 'should return the value returned by the class method' do
      @punch.list.should == @list
    end
  end
end
