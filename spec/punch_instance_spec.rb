require File.dirname(__FILE__) + '/spec_helper.rb'

describe Punch, 'instance' do
  describe 'when initialized' do
    before :each do
      @project = 'proj'
    end
    
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
end
