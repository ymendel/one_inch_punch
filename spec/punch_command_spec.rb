require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'punch command' do
  def run_command(*args)
    Object.const_set(:ARGV, args)
    begin
      eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin punch]))
    rescue SystemExit
    end
  end
  
  before :each do
    [:ARGV, :OPTIONS, :MANDATORY_OPTIONS].each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end
    
    self.stubs(:puts)
  end
  
  it 'should exist' do
    lambda { run_command }.should_not raise_error(Errno::ENOENT)
  end
  
  it 'should require a command' do
    self.expects(:puts).with(regexp_matches(/usage.+command/i))
    run_command
  end
  
  describe "when the command is 'total'" do
    before :each do
      Punch.stubs(:load)
      Punch.stubs(:total)
      @project = 'myproj'
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('total')
    end
    
    it 'should get the total for the requested project' do
      Punch.expects(:total).with(@project)
      run_command('total', @project)
    end
    
    it 'should get the total for all projects if none given' do
      Punch.expects(:total).with(nil)
      run_command('total')
    end
    
    it 'should output the total' do
      total = 'total data'
      Punch.stubs(:total).returns(total)
      self.expects(:puts).with(total.inspect)
      run_command('total')
    end
    
    it 'should not write the data' do
      Punch.expects(:write).never
      run_command('total')
    end
  end
end
