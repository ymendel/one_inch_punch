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
end
