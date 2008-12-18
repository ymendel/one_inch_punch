require File.dirname(__FILE__) + '/spec_helper.rb'

def run_command(*args)
  Object.const_set(:ARGV, args)
  begin
    eval File.read(File.join(File.dirname(__FILE__), *%w[.. bin punch]))
  rescue SystemExit
  end
end


describe 'punch command' do
  before do
    [:ARGV, :OPTIONS, :MANDATORY_OPTIONS].each do |const|
      Object.send(:remove_const, const) if Object.const_defined?(const)
    end
    
    self.stub!(:puts)
    Punch.stub!(:load)
    Punch.stub!(:write)
    
    @project = 'myproj'
  end
  
  it 'should exist' do
    lambda { run_command }.should.not.raise(Errno::ENOENT)
  end
  
  it 'should require a command' do
    self.should.receive(:puts) do |output|
      output.should.match(/usage.+command/i)
    end
    run_command
  end
  
  describe "when the command is 'total'" do
    before do
      Punch.stub!(:total)
    end
    
    it 'should load punch data' do
      Punch.should.receive(:load)
      run_command('total', @project)
    end
    
    it 'should get the total for the requested project' do
      Punch.should.receive(:total) do |proj, _|
        proj.should == @project
      end
      run_command('total', @project)
    end
    
    it 'should get the total for all projects if none given' do
      Punch.should.receive(:total) do |proj, _|
        proj.should.be.nil
      end
      run_command('total')
    end
    
    it 'should output the total' do
      result = 'total data'
      Punch.stub!(:total).and_return(result)
      self.should.receive(:puts).with(result.inspect)
      run_command('total', @project)
    end
    
    it 'should output the total as YAML if no project given' do
      result = 'total data'
      Punch.stub!(:total).and_return(result)
      self.should.receive(:puts).with(result.to_yaml)
      run_command('total')
    end
    
    it 'should not write the data' do
      Punch.should.receive(:write).never
      run_command('total')
    end
    
    describe 'when options specified' do
      it "should pass on an 'after' time option given by --after" do
        time_option = '2008-08-26 09:47'
        time = Time.local(2008, 8, 26, 9, 47)
        Punch.should.receive(:total) do |proj, options|
          proj.should == @project
          options[:after].should == time
        end
        run_command('total', @project, '--after', time_option)
      end
      
      it "should pass on a 'before' time option given by --before" do
        time_option = '2008-08-23 15:39'
        time = Time.local(2008, 8, 23, 15, 39)
        Punch.should.receive(:total) do |proj, options|
          proj.should == @project
          options[:before].should == time
        end
        run_command('total', @project, '--before', time_option)
      end
      
      it 'should handle a time option given as a date' do
        time_option = '2008-08-23'
        time = Time.local(2008, 8, 23)
        Punch.should.receive(:total) do |proj, options|
          proj.should == @project
          options[:before].should == time
        end
        run_command('total', @project, '--before', time_option)
      end
      
      it 'should accept time options if no project given' do
        time_option = '2008-08-26 09:47'
        time = Time.local(2008, 8, 26, 9, 47)
        Punch.should.receive(:total) do |proj, options|
          proj.should.be.nil
          options[:before].should == time
        end
        run_command('total', '--before', time_option)
      end
      
      it 'should also pass the formatting option' do
        time_option = '2008-08-26 09:47'
        Punch.should.receive(:total) do |proj, options|
          proj.should == @project
          options[:format].should == true
        end
        run_command('total', @project, '--before', time_option)
      end
    end
    
    it 'should pass only the formatting option if no options specified' do
      Punch.should.receive(:total) do |proj, options|
        proj.should == @project
        options[:format].should == true
      end
      run_command('total', @project)
    end
  end

  describe "when the command is 'status'" do
    before do
      Punch.stub!(:status)
    end
    
    it 'should load punch data' do
      Punch.should.receive(:load)
      run_command('status', @project)
    end
    
    it 'should get the status for the requested project' do
      Punch.should.receive(:status).with(@project, {})
      run_command('status', @project)
    end
    
    it 'should get the status for all projects if none given' do
      Punch.should.receive(:status).with(nil, {})
      run_command('status')
    end
    
    it 'should output the status' do
      result = 'status data'
      Punch.stub!(:status).and_return(result)
      self.should.receive(:puts).with(result.inspect)
      run_command('status', @project)
    end
    
    it 'should output the status as YAML if no project given' do
      result = 'status data'
      Punch.stub!(:status).and_return(result)
      self.should.receive(:puts).with(result.to_yaml)
      run_command('status')
    end
    
    it 'should pass a true full option if specified on the command line (with --full)' do
      Punch.should.receive(:status).with(@project, :full => true)
      run_command('status', @project, '--full')
    end
    
    it 'should pass a true full option if specified on the command line (with --full) and no project given' do
      Punch.should.receive(:status).with(nil, :full => true)
      run_command('status', '--full')
    end
    
    it 'should output the status as YAML if a full option is given' do
      result = 'status data'
      Punch.stub!(:status).and_return(result)
      self.should.receive(:puts).with(result.to_yaml)
      run_command('status', @project, '--full')
    end
    
    it 'should output the status as YAML if no project given even if a full option is given' do
      result = 'status data'
      Punch.stub!(:status).and_return(result)
      self.should.receive(:puts).with(result.to_yaml)
      run_command('status', '--full')
    end
    
    it 'should not write the data' do
      Punch.should.receive(:write).never
      run_command('status')
    end
  end
  
  describe "when the command is 'in'" do
    before do
      Punch.stub!(:in)
    end
    
    it 'should load punch data' do
      Punch.should.receive(:load)
      run_command('in', @project)
    end
    
    it 'should punch in to the given project' do
      Punch.should.receive(:in).with(@project, {})
      run_command('in', @project)
    end
    
    it 'should pass a time if specified on the command line (with --time)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.should.receive(:in) do |proj, options|
        proj.should == @project
        options[:time].should == time
      end
      run_command('in', @project, '--time', time_option)
    end
    
    it 'should pass a time if specified on the command line (with --at)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.should.receive(:in) do |proj, options|
        proj.should == @project
        options[:time].should == time
      end
      run_command('in', @project, '--at', time_option)
    end
    
    it 'should pass a message if specified on the command line (with --message)' do
      message = 'About to do some amazing work'
      Punch.should.receive(:in) do |proj, options|
        proj.should == @project
        options[:message].should == message
      end
      run_command('in', @project, '--message', message)
    end
    
    it 'should pass a message if specified on the command line (with -m)' do
      message = 'About to do some amazing work'
      Punch.should.receive(:in) do |proj, options|
        proj.should == @project
        options[:message].should == message
      end
      run_command('in', @project, '-m', message)
    end
    
    describe 'when punched in successfully' do
      before do
        Punch.stub!(:in).and_return(true)
      end
      
      it 'should write the data' do
        Punch.should.receive(:write)
        run_command('in', @project)
      end
      
      it 'should not print anything' do
        self.should.receive(:puts).never
        run_command('in', @project)
      end
    end
    
    describe 'when not punched in successfully' do
      before do
        Punch.stub!(:in).and_return(false)
      end
      
      it 'should not write the data' do
        Punch.should.receive(:write).never
        run_command('in', @project)
      end
      
      it 'should print a message' do
        self.should.receive(:puts) do |output|
          output.should.match(/already.+in/i)
        end
        run_command('in', @project)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.should.receive(:puts) do |output|
          output.should.match(/project.+require/i)
        end
        run_command('in')
      end
      
      it 'should not punch in' do
        Punch.stub!(:write)
        Punch.should.receive(:in).never
        run_command('in')
      end
      
      it 'should not write the data' do
        Punch.should.receive(:write).never
        run_command('in')
      end
    end
  end

  describe "when the command is 'out'" do
    before do
      Punch.stub!(:out)
    end
    
    it 'should load punch data' do
      Punch.should.receive(:load)
      run_command('out', @project)
    end
    
    it 'should punch out of the given project' do
      Punch.should.receive(:out).with(@project, {})
      run_command('out', @project)
    end
    
    it 'should pass a time if specified on the command line (with --time)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.should.receive(:out) do |proj, options|
        proj.should == @project
        options[:time].should == time
      end
      run_command('out', @project, '--time', time_option)
    end
    
    it 'should pass a time if specified on the command line (with --at)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.should.receive(:out) do |proj, options|
        proj.should == @project
        options[:time].should == time
      end
      run_command('out', @project, '--at', time_option)
    end
    
    it 'should pass a message if specified on the command line (with --message)' do
      message = 'Finished doing some stellar work'
      Punch.should.receive(:out) do |proj, options|
        proj.should == @project
        options[:message].should == message
      end
      run_command('out', @project, '--message', message)
    end
    
    it 'should pass a message if specified on the command line (with -m)' do
      message = 'Finished doing some stellar work'
      Punch.should.receive(:out) do |proj, options|
        proj.should == @project
        options[:message].should == message
      end
      run_command('out', @project, '-m', message)
    end
    
    describe 'if no project given' do
      it 'should punch out of all projects' do
        Punch.should.receive(:out).with(nil, {})
        run_command('out')
      end
      
      it 'should pass a time if specified on the command line (with --time)' do
        time_option = '2008-08-23 15:39'
        time = Time.local(2008, 8, 23, 15, 39)
        Punch.should.receive(:out) do |proj, options|
          proj.should.be.nil
          options[:time].should == time
        end
        run_command('out', '--time', time_option)
      end
      
      it 'should pass a time if specified on the command line (with --at)' do
        time_option = '2008-08-23 15:39'
        time = Time.local(2008, 8, 23, 15, 39)
        Punch.should.receive(:out) do |proj, options|
          proj.should.be.nil
          options[:time].should == time
        end
        run_command('out', '--at', time_option)
      end
      
      it 'should pass a message if specified on the command line (with --message)' do
        message = 'Finished doing some stellar work'
        Punch.should.receive(:out) do |proj, options|
          proj.should.be.nil
          options[:message].should == message
        end
        run_command('out', '--message', message)
      end
      
      it 'should pass a message if specified on the command line (with -m)' do
        message = 'Finished doing some stellar work'
        Punch.should.receive(:out) do |proj, options|
          proj.should.be.nil
          options[:message].should == message
        end
        run_command('out', '-m', message)
      end
    end
    
    describe 'when punched out successfully' do
      before do
        Punch.stub!(:out).and_return(true)
      end
      
      it 'should write the data' do
        Punch.should.receive(:write)
        run_command('out', @project)
      end
      
      it 'should not print anything' do
        self.should.receive(:puts).never
        run_command('out', @project)
      end
      
      describe 'and no project given' do
        it 'should not print anything' do
          self.should.receive(:puts).never
          run_command('out')
        end
      end
    end
    
    describe 'when not punched out successfully' do
      before do
        Punch.stub!(:out).and_return(false)
      end
      
      it 'should not write the data' do
        Punch.should.receive(:write).never
        run_command('out', @project)
      end
      
      it 'should print a message' do
        self.should.receive(:puts) do |output|
          output.should.match(/already.+out/i)
        end
        run_command('out', @project)
      end
      
      describe 'and no project given' do
        it 'should print a message' do
          self.should.receive(:puts) do |output|
            output.should.match(/already.+out/i)
          end
          run_command('out')
        end
      end
    end
  end
  
  describe "when the command is 'delete'" do
    before do
      Punch.stub!(:delete)
    end
    
    it 'should load punch data' do
      Punch.should.receive(:load)
      run_command('delete', @project)
    end
    
    it 'should delete the given project' do
      Punch.stub!(:write)
      Punch.should.receive(:delete).with(@project)
      run_command('delete', @project)
    end
    
    it 'should output the result' do
      result = 'result'
      Punch.stub!(:delete).and_return(result)
      self.should.receive(:puts).with(result.inspect)
      run_command('delete', @project)
    end
    
    describe 'when deleted successfully' do
      it 'should write the data' do
        Punch.stub!(:delete).and_return(true)
        Punch.should.receive(:write)
        run_command('delete', @project)
      end
    end
    
    describe 'when not deleted successfully' do
      it 'should not write the data' do
        Punch.stub!(:delete).and_return(nil)
        Punch.should.receive(:write).never
        run_command('delete', @project)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.should.receive(:puts) do |output|
          output.should.match(/project.+require/i)
        end
        run_command('delete')
      end
      
      it 'should not delete' do
        Punch.stub!(:write)
        Punch.should.receive(:delete).never
        run_command('delete')
      end
      
      it 'should not write the data' do
        Punch.should.receive(:write).never
        run_command('delete')
      end
    end
  end
  
  describe "when the command is 'log'" do
    before do
      Punch.stub!(:log)
      @message = 'log message'
    end
    
    it 'should load punch data' do
      Punch.should.receive(:load)
      run_command('log', @project, @message)
    end
    
    it 'should log a message for the given project' do
      Punch.stub!(:write)
      Punch.should.receive(:log).with(@project, @message, {})
      run_command('log', @project, @message)
    end
    
    it 'should pass a time if specified on the command line (with --time)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.should.receive(:log) do |proj, msg, options|
        proj.should == @project
        msg.should == @message
        options[:time].should == time
      end
      run_command('log', @project, @message, '--time', time_option)
    end
    
    it 'should pass a time if specified on the command line (with --at)' do
      time_option = '2008-08-23 15:39'
      time = Time.local(2008, 8, 23, 15, 39)
      Punch.should.receive(:log) do |proj, msg, options|
        proj.should == @project
        msg.should == @message
        options[:time].should == time
      end
      run_command('log', @project, @message, '--at', time_option)
    end
    
    describe 'when logged successfully' do
      before do
        Punch.stub!(:log).and_return(true)
      end
      
      it 'should write the data' do
        Punch.should.receive(:write)
        run_command('log', @project, @message)
      end
      
      it 'should not print anything' do
        self.should.receive(:puts).never
        run_command('log', @project, @message)
      end
    end
    
    describe 'when not logged successfully' do
      before do
        Punch.stub!(:log).and_return(false)
      end
      
      it 'should not write the data' do
        Punch.should.receive(:write).never
        run_command('log', @project, @message)
      end
      
      it 'should print a message' do
        self.should.receive(:puts) do |output|
          output.should.match(/not.+in/i)
        end
        run_command('log', @project, @message)
      end
    end
    
    describe 'when no project given' do
      it 'should display an error message' do
        self.should.receive(:puts) do |output|
          output.should.match(/project.+require/i)
        end
        run_command('log')
      end
      
      it 'should not log' do
        Punch.stub!(:write)
        Punch.should.receive(:log).never
        run_command('log')
      end
      
      it 'should not write the data' do
        Punch.should.receive(:write).never
        run_command('log')
      end
    end
    
    describe 'when no message given' do
      it 'should display an error message' do
        self.should.receive(:puts) do |output|
          output.should.match(/message.+require/i)
        end
        run_command('log', @project)
      end
      
      it 'should not log' do
        Punch.stub!(:write)
        Punch.should.receive(:log).never
        run_command('log', @project)
      end
      
      it 'should not write the data' do
        Punch.should.receive(:write).never
        run_command('log', @project)
      end
    end
  end
  
  describe "when the command is 'list'" do
    before do
      Punch.stub!(:list)
    end
    
    it 'should load punch data' do
      Punch.should.receive(:load)
      run_command('list', @project)
    end
    
    it 'should get the data for the requested project' do
      Punch.should.receive(:list) do |proj, _|
        proj.should == @project
      end
      run_command('list', @project)
    end
    
    it 'should get the data for all projects if none given' do
      Punch.should.receive(:list) do |proj, _|
        proj.should.be.nil
      end
      run_command('list')
    end
    
    it 'should output the list data' do
      result = 'list data'
      Punch.stub!(:list).and_return(result)
      self.should.receive(:puts).with(result.to_yaml)
      run_command('list')
    end
    
    describe 'when options specified' do
      it "should pass on an 'after' time option given by --after" do
        time_option = '2008-08-26 09:47'
        time = Time.local(2008, 8, 26, 9, 47)
        Punch.should.receive(:list) do |proj, options|
          proj.should == @project
          options[:after].should == time
        end
        run_command('list', @project, '--after', time_option)
      end
      
      it "should pass on a 'before' time option given by --before" do
        time_option = '2008-08-23 15:39'
        time = Time.local(2008, 8, 23, 15, 39)
        Punch.should.receive(:list) do |proj, options|
          proj.should == @project
          options[:before].should == time
        end
        run_command('list', @project, '--before', time_option)
      end
      
      it 'should handle a time option given as a date' do
        time_option = '2008-08-23'
        time = Time.local(2008, 8, 23)
        Punch.should.receive(:list) do |proj, options|
          proj.should == @project
          options[:before].should == time
        end
        run_command('list', @project, '--before', time_option)
      end
      
      it 'should accept time options if no project given' do
        time_option = '2008-08-26 09:47'
        time = Time.local(2008, 8, 26, 9, 47)
        Punch.should.receive(:list) do |proj, options|
          proj.should.be.nil
          options[:before].should == time
        end
        run_command('list', '--before', time_option)
      end
    end
    
    it 'should not write the data' do
      Punch.should.receive(:write).never
      run_command('list')
    end
  end
  
  describe 'when the command is unknown' do
    it 'should not error' do
      lambda { run_command('bunk') }.should.not.raise
    end
    
    it 'should print a message' do
      self.should.receive(:puts) do |output|
        output.should.match(/command.+unknown/i)
      end
      run_command('bunk')
    end
    
    it 'should not write the data' do
      Punch.should.receive(:write).never
      run_command('bunk')
    end
    
    it 'should not run any punch command' do
      [:in, :out, :delete, :status, :total, :log, :list].each do |command|
        Punch.should.receive(command).never
      end
      run_command('bunk')
    end
  end
end
