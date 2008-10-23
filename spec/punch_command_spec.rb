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
    
    @states = {}
    %w[puts load write].each do |state|
      @states[state] = states(state).starts_as('setup')
    end
    
    self.stubs(:puts).when(@states['puts'].is('setup'))
    Punch.stubs(:load).when(@states['load'].is('setup'))
    Punch.stubs(:write).when(@states['write'].is('setup'))
    
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
      Punch.expects(:total).with(@project, anything)
      run_command('total', @project)
    end
    
    it 'should get the total for all projects if none given' do
      Punch.expects(:total).with(nil, anything)
      run_command('total')
    end
    
    it 'should output the total' do
      result = 'total data'
      Punch.stubs(:total).returns(result)
      self.expects(:puts).with(result.inspect)
      run_command('total')
    end
    
    it 'should not write the data' do
      @states['write'].become('test')
      Punch.expects(:write).never.when(@states['write'].is('test'))
      run_command('total')
    end
    
    describe 'when options specified' do
      it "should pass on an 'after' time option given by --after" do
        time_option = '2008-08-26 09:47'
        time = Time.local(2008, 8, 26, 9, 47)
        Punch.expects(:total).with(@project, has_entry(:after => time))
        run_command('total', @project, '--after', time_option)
      end
      
      it "should pass on a 'before' time option given by --before" do
        time_option = '2008-08-23 15:39'
        time = Time.local(2008, 8, 23, 15, 39)
        Punch.expects(:total).with(@project, has_entry(:before => time))
        run_command('total', @project, '--before', time_option)
      end
      
      it 'should handle a time option given as a date' do
        time_option = '2008-08-23'
        time = Time.local(2008, 8, 23)
        Punch.expects(:total).with(@project, has_entry(:before => time))
        run_command('total', @project, '--before', time_option)
      end
      
      it 'should accept time options if no project given' do
        time_option = '2008-08-26 09:47'
        time = Time.local(2008, 8, 26, 9, 47)
        Punch.expects(:total).with(nil, has_entry(:before => time))
        run_command('total', '--before', time_option)
      end
      
      it 'should also pass the formatting option' do
        time_option = '2008-08-26 09:47'
        Punch.expects(:total).with(@project, has_entry(:format => true))
        run_command('total', @project, '--before', time_option)
      end
    end
    
    it 'should pass only the formatting option if no options specified' do
      Punch.expects(:total).with(@project, {:format => true})
      run_command('total', @project)
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
      result = 'status data'
      Punch.stubs(:status).returns(result)
      self.expects(:puts).with(result.inspect)
      run_command('status')
    end
    
    it 'should not write the data' do
      @states['write'].become('test')
      Punch.expects(:write).never.when(@states['write'].is('test'))
      run_command('status')
    end
  end
  
  describe "when the command is 'in'" do
    before :each do
      @states['in'] = states('in').starts_as('setup')
      Punch.stubs(:in).when(@states['write'].is('setup'))
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('in', @project)
    end
    
    it 'should punch in to the given project' do
      Punch.expects(:in).with(@project, {})
      run_command('in', @project)
    end
    
    it 'should pass a time if specified on the command line (with --time)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.expects(:in).with(@project, has_entry(:time => time))
      run_command('in', @project, '--time', time_option)
    end
    
    it 'should pass a time if specified on the command line (with --at)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.expects(:in).with(@project, has_entry(:time => time))
      run_command('in', @project, '--at', time_option)
    end
    
    it 'should pass a message if specified on the command line (with --message)' do
      message = 'About to do some amazing work'
      Punch.expects(:in).with(@project, has_entry(:message => message))
      run_command('in', @project, '--message', message)
    end
    
    it 'should pass a message if specified on the command line (with -m)' do
      message = 'About to do some amazing work'
      Punch.expects(:in).with(@project, has_entry(:message => message))
      run_command('in', @project, '-m', message)
    end
    
    describe 'when punched in successfully' do
      before :each do
        Punch.stubs(:in).returns(true)
      end
      
      it 'should write the data' do
        Punch.expects(:write)
        run_command('in', @project)
      end
      
      it 'should not print anything' do
        @states['puts'].become('test')
        self.expects(:puts).never.when(@states['puts'].is('test'))
        run_command('in', @project)
      end
    end
    
    describe 'when not punched in successfully' do
      before :each do
        Punch.stubs(:in).returns(false)
      end
      
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.expects(:write).never.when(@states['write'].is('test'))
        run_command('in', @project)
      end
      
      it 'should print a message' do
        self.expects(:puts).with(regexp_matches(/already.+in/i))
        run_command('in', @project)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/project.+require/i))
        run_command('in')
      end
      
      it 'should not punch in' do
        @states['in'].become('test')
        Punch.stubs(:write)
        Punch.expects(:in).never.when(@states['in'].is('test'))
        run_command('in')
      end
      
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.expects(:write).never.when(@states['write'].is('test'))
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
      Punch.expects(:out).with(@project, {})
      run_command('out', @project)
    end
    
    it 'should pass a time if specified on the command line (with --time)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.expects(:out).with(@project, has_entry(:time => time))
      run_command('out', @project, '--time', time_option)
    end
    
    it 'should pass a time if specified on the command line (with --at)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.expects(:out).with(@project, has_entry(:time => time))
      run_command('out', @project, '--at', time_option)
    end
    
    it 'should pass a message if specified on the command line (with --message)' do
      message = 'Finished doing some stellar work'
      Punch.expects(:out).with(@project, has_entry(:message => message))
      run_command('out', @project, '--message', message)
    end
    
    it 'should pass a message if specified on the command line (with -m)' do
      message = 'Finished doing some stellar work'
      Punch.expects(:out).with(@project, has_entry(:message => message))
      run_command('out', @project, '-m', message)
    end
    
    describe 'if no project given' do
      it 'should punch out of all projects' do
        Punch.expects(:out).with(nil, {})
        run_command('out')
      end
      
      it 'should pass a time if specified on the command line (with --time)' do
        time_option = '2008-08-23 15:39'
        time = Time.local(2008, 8, 23, 15, 39)
        Punch.expects(:out).with(nil, has_entry(:time => time))
        run_command('out', '--time', time_option)
      end
      
      it 'should pass a time if specified on the command line (with --at)' do
        time_option = '2008-08-23 15:39'
        time = Time.local(2008, 8, 23, 15, 39)
        Punch.expects(:out).with(nil, has_entry(:time => time))
        run_command('out', '--at', time_option)
      end
      
      it 'should pass a message if specified on the command line (with --message)' do
        message = 'Finished doing some stellar work'
        Punch.expects(:out).with(nil, has_entry(:message => message))
        run_command('out', '--message', message)
      end
      
      it 'should pass a message if specified on the command line (with -m)' do
        message = 'Finished doing some stellar work'
        Punch.expects(:out).with(nil, has_entry(:message => message))
        run_command('out', '-m', message)
      end
    end
    
    describe 'when punched out successfully' do
      before :each do
        Punch.stubs(:out).returns(true)
      end
      
      it 'should write the data' do
        Punch.expects(:write)
        run_command('out', @project)
      end
      
      it 'should not print anything' do
        @states['puts'].become('test')
        self.expects(:puts).never.when(@states['puts'].is('test'))
        run_command('out', @project)
      end
      
      describe 'and no project given' do
        it 'should not print anything' do
          @states['puts'].become('test')
          self.expects(:puts).never.when(@states['puts'].is('test'))
          run_command('out')
        end
      end
    end
    
    describe 'when not punched out successfully' do
      before :each do
        Punch.stubs(:out).returns(false)
      end
      
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.expects(:write).never.when(@states['write'].is('test'))
        run_command('out', @project)
      end
      
      it 'should print a message' do
        self.expects(:puts).with(regexp_matches(/already.+out/i))
        run_command('out', @project)
      end
      
      describe 'and no project given' do
        it 'should print a message' do
          self.expects(:puts).with(regexp_matches(/already.+out/i))
          run_command('out')
        end
      end
    end
  end
  
  describe "when the command is 'delete'" do
    before :each do
      @states['delete'] = states('delete').starts_as('setup')
      Punch.stubs(:delete).when(@states['write'].is('setup'))
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('delete', @project)
    end
    
    it 'should delete the given project' do
      Punch.stubs(:write)
      Punch.expects(:delete).with(@project)
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
        Punch.stubs(:delete).returns(true)
        Punch.expects(:write)
        run_command('delete', @project)
      end
    end
    
    describe 'when not deleted successfully' do
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.stubs(:delete).returns(nil)
        Punch.expects(:write).never.when(@states['write'].is('test'))
        run_command('delete', @project)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/project.+require/i))
        run_command('delete')
      end
      
      it 'should not delete' do
        @states['delete'].become('test')
        Punch.stubs(:write)
        Punch.expects(:delete).never.when(@states['delete'].is('test'))
        run_command('delete')
      end
      
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.expects(:write).never.when(@states['write'].is('test'))
        run_command('delete')
      end
    end
  end
  
  describe "when the command is 'log'" do
    before :each do
      @states['log'] = states('log').starts_as('setup')
      Punch.stubs(:log).when(@states['log'].is('setup'))
      @message = 'log message'
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('log', @project, @message)
    end
    
    it 'should log a message for the given project' do
      Punch.stubs(:write)
      Punch.expects(:log).with(@project, @message)
      run_command('log', @project, @message)
    end
    
    describe 'when logged successfully' do
      before :each do
        Punch.stubs(:log).returns(true)
      end
      
      it 'should write the data' do
        Punch.expects(:write)
        run_command('log', @project, @message)
      end
      
      it 'should not print anything' do
        @states['puts'].become('test')
        self.expects(:puts).never.when(@states['write'].is('test'))
        run_command('log', @project, @message)
      end
    end
    
    describe 'when not deleted successfully' do
      before :each do
        Punch.stubs(:log).returns(false)
      end
      
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.expects(:write).never.when(@states['write'].is('test'))
        run_command('log', @project, @message)
      end
      
      it 'should print a message' do
        self.expects(:puts).with(regexp_matches(/not.+in/i))
        run_command('log', @project, @message)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/project.+require/i))
        run_command('log')
      end
      
      it 'should not log' do
        @states['log'].become('test')
        Punch.stubs(:write)
        Punch.expects(:log).never.when(@states['log'].is('test'))
        run_command('log')
      end
      
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.expects(:write).never.when(@states['write'].is('test'))
        run_command('log')
      end
    end
    
    describe 'when no message given' do
      it 'should display an error message' do
        self.expects(:puts).with(regexp_matches(/message.+require/i))
        run_command('log', @project)
      end
      
      it 'should not log' do
        @states['log'].become('test')
        Punch.stubs(:write)
        Punch.expects(:log).never.when(@states['log'].is('test'))
        run_command('log', @project)
      end
      
      it 'should not write the data' do
        @states['write'].become('test')
        Punch.expects(:write).never.when(@states['write'].is('test'))
        run_command('log', @project)
      end
    end
  end
  
  describe "when the command is 'list'" do
    before :each do
      Punch.stubs(:list)
    end
    
    it 'should load punch data' do
      Punch.expects(:load)
      run_command('list', @project)
    end
    
    it 'should get the data for the requested project' do
      Punch.expects(:list).with(@project)
      run_command('list', @project)
    end
    
    it 'should get the data for all projects if none given' do
      Punch.expects(:list).with(nil)
      run_command('list')
    end
    
    it 'should output the list data' do
      result = 'list data'
      Punch.stubs(:list).returns(result)
      self.expects(:puts).with(result.inspect)
      run_command('list')
    end
    
    it 'should not write the data' do
      @states['write'].become('test')
      Punch.expects(:write).never.when(@states['write'].is('test'))
      run_command('list')
    end
  end
  
  describe 'when the command is unknown' do
    it 'should not error' do
      lambda { run_command('bunk') }.should_not raise_error
    end
    
    it 'should print a message' do
      self.expects(:puts).with(regexp_matches(/command.+unknown/i))
      run_command('bunk')
    end
    
    it 'should not write the data' do
      @states['write'].become('test')
      Punch.expects(:write).never.when(@states['write'].is('test'))
      run_command('bunk')
    end
    
    it 'should not run any punch command' do
      [:in, :out, :delete, :status, :total, :log].each do |command|
        Punch.expects(command).never
      end
      run_command('bunk')
    end
  end
end
