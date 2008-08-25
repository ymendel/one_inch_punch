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
    
    Punch.stubs(:load)
    @test = states('test').starts_as('setup')
    Punch.stubs(:write).when(@test.is('setup'))
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
      @test.become('test')
      Punch.expects(:write).never.when(@test.is('test'))
      run_command('total')
    end
  end
  
  describe "when the command is 'in'" do
    before :each do
      Punch.stubs(:in).when(@test.is('setup'))
      @project = 'myproj'
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('in')
    end
    
    it 'should punch in to the given project' do
      @test.become('test')
      Punch.stubs(:write)
      Punch.expects(:in).with(@project).when(@test.is('test'))
      run_command('in', @project)
    end
    
    it 'should output the result' do
      result = 'result'
      Punch.stubs(:in).returns(result)
      self.expects(:puts).with(result.inspect)
      run_command('in', @project)
    end
    
    describe 'when punched in successfully' do
      it 'should write the data' do
        @test.become('test')
        Punch.stubs(:in).returns(true)
        Punch.expects(:write).when(@test.is('test'))
        run_command('in', @project)
      end
    end
    
    describe 'when not punched in successfully' do
      it 'should not write the data' do
        @test.become('test')
        Punch.stubs(:in).returns(false)
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('in', @project)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/project.+require/i))
        run_command('in')
      end
      
      it 'should not punch in' do
        @test.become('test')
        Punch.stubs(:write)
        Punch.expects(:in).never.when(@test.is('test'))
        run_command('in')
      end
      
      it 'should not write the data' do
        @test.become('test')
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('in')
      end
    end
  end
end
