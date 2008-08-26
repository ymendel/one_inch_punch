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
    @project = 'myproj'
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
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('total', @project)
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

  describe "when the command is 'status'" do
    before :each do
      Punch.stubs(:status)
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('status', @project)
    end
    
    it 'should get the status for the requested project' do
      Punch.expects(:status).with(@project)
      run_command('status', @project)
    end
    
    it 'should get the status for all projects if none given' do
      Punch.expects(:status).with(nil)
      run_command('status')
    end
    
    it 'should output the status' do
      status = 'status data'
      Punch.stubs(:status).returns(status)
      self.expects(:puts).with(status.inspect)
      run_command('status')
    end
    
    it 'should not write the data' do
      @test.become('test')
      Punch.expects(:write).never.when(@test.is('test'))
      run_command('status')
    end
  end
  
  describe "when the command is 'in'" do
    before :each do
      Punch.stubs(:in).when(@test.is('setup'))
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('in', @project)
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

  describe "when the command is 'out'" do
    before :each do
      Punch.stubs(:out)
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('out', @project)
    end
    
    it 'should punch out of the given project' do
      Punch.expects(:out).with(@project)
      run_command('out', @project)
    end
    
    it 'should punch out of all projects if none given' do
      Punch.expects(:out).with(nil)
      run_command('out')
    end
    
    it 'should output the result' do
      result = 'result'
      Punch.stubs(:out).returns(result)
      self.expects(:puts).with(result.inspect)
      run_command('out', @project)
    end
    
    describe 'when punched out successfully' do
      it 'should write the data' do
        @test.become('test')
        Punch.stubs(:out).returns(true)
        Punch.expects(:write).when(@test.is('test'))
        run_command('out', @project)
      end
    end
    
    describe 'when not punched out successfully' do
      it 'should not write the data' do
        @test.become('test')
        Punch.stubs(:out).returns(false)
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('out', @project)
      end
    end
  end
  
  describe "when the command is 'delete'" do
    before :each do
      Punch.stubs(:delete).when(@test.is('setup'))
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('delete', @project)
    end
    
    it 'should delete the given project' do
      @test.become('test')
      Punch.stubs(:write)
      Punch.expects(:delete).with(@project).when(@test.is('test'))
      run_command('delete', @project)
    end
    
    it 'should output the result' do
      result = 'result'
      Punch.stubs(:delete).returns(result)
      self.expects(:puts).with(result.inspect)
      run_command('delete', @project)
    end
    
    describe 'when deleted successfully' do
      it 'should write the data' do
        @test.become('test')
        Punch.stubs(:delete).returns(true)
        Punch.expects(:write).when(@test.is('test'))
        run_command('delete', @project)
      end
    end
    
    describe 'when not deleted successfully' do
      it 'should not write the data' do
        @test.become('test')
        Punch.stubs(:delete).returns(nil)
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('delete', @project)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/project.+require/i))
        run_command('delete')
      end
      
      it 'should not delete' do
        @test.become('test')
        Punch.stubs(:write)
        Punch.expects(:delete).never.when(@test.is('test'))
        run_command('delete')
      end
      
      it 'should not write the data' do
        @test.become('test')
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('delete')
      end
    end
  end
  
  describe "when the command is 'log'" do
    before :each do
      Punch.stubs(:log).when(@test.is('setup'))
      @message = 'log message'
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('log', @project, @message)
    end
    
    it 'should log a message for the given project' do
      @test.become('test')
      Punch.stubs(:write)
      Punch.expects(:log).with(@project, @message).when(@test.is('test'))
      run_command('log', @project, @message)
    end
        
    it 'should output the result' do
      result = 'result'
      Punch.stubs(:log).returns(result)
      self.expects(:puts).with(result.inspect)
      run_command('log', @project, @message)
    end
    
    describe 'when logged successfully' do
      it 'should write the data' do
        @test.become('test')
        Punch.stubs(:log).returns(true)
        Punch.expects(:write).when(@test.is('test'))
        run_command('log', @project, @message)
      end
    end
    
    describe 'when not deleted successfully' do
      it 'should not write the data' do
        @test.become('test')
        Punch.stubs(:log).returns(false)
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('log', @project, @message)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/project.+require/i))
        run_command('log')
      end
      
      it 'should not log' do
        @test.become('test')
        Punch.stubs(:write)
        Punch.expects(:log).never.when(@test.is('test'))
        run_command('log')
      end
      
      it 'should not write the data' do
        @test.become('test')
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('log')
      end
    end
    
    describe 'when no message given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/message.+require/i))
        run_command('log', @project)
      end
      
      it 'should not log' do
        @test.become('test')
        Punch.stubs(:write)
        Punch.expects(:log).never.when(@test.is('test'))
        run_command('log', @project)
      end
      
      it 'should not write the data' do
        @test.become('test')
        Punch.expects(:write).never.when(@test.is('test'))
        run_command('log', @project)
      end
    end
  end
end
