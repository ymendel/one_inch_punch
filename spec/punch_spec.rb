require File.dirname(__FILE__) + '/spec_helper.rb'

describe Punch do
  it 'should load data' do
    Punch.should respond_to(:load)
  end
  
  describe 'when loading data' do
    before :each do
      @data = <<-EOD
      ---
      rip: 
      - out: 2008-05-19T18:34:39.00-05:00
        log: 
        - punch in @ 2008-05-19T17:09:05-05:00
        - punch out @ 2008-05-19T18:34:39-05:00
        total: "01:25:34"
        in: 2008-05-19T17:09:05.00-05:00
      - out: 2008-05-19T21:04:03.00-05:00
        total: "00:50:22"
        log: 
        - punch in @ 2008-05-19T20:13:41-05:00
        - punch out @ 2008-05-19T21:04:03-05:00
        in: 2008-05-19T20:13:41.00-05:00
      ps: 
      - out: 2008-05-19T12:18:52.00-05:00
        log: 
        - punch in @ 2008-05-19T11:23:35-05:00
        - punch out @ 2008-05-19T12:18:52-05:00
        total: "00:55:17"
        in: 2008-05-19T11:23:35.00-05:00
      EOD
      File.stubs(:read).returns(@data)
      
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      
      Punch.reset
    end
    
    it 'should read the ~/.punch.yml file' do
      File.expects(:read).with(File.expand_path('~/.punch.yml')).returns(@data)
      Punch.load
    end
    
    describe 'when the file is found' do
      it 'should load the data as yaml' do
        Punch.load
        Punch.data.should == YAML.load(@data)
      end
      
      it 'should return true' do
        Punch.load.should == true
      end
      
      describe 'and is empty' do
        before :each do
          File.stubs(:read).returns('')
        end
        
        it 'should load the data as yaml' do
          Punch.load
          Punch.data.should == {}
        end

        it 'should return true' do
          Punch.load.should == true
        end
      end
    end
    
    describe 'when no file is found' do
      before :each do
        File.stubs(:read).raises(Errno::ENOENT)
      end
      
      it 'should set the data to an empty hash' do
        Punch.load
        Punch.data.should == {}
      end
      
      it 'should return false' do
        Punch.load.should == true
      end
    end
    
    describe 'and returning data' do
      it 'should return the data if set' do
        val = { 'rip' => [] }
        Punch.data = val
        Punch.data.should == val
      end
      
      it 'should load the data if not set' do
        Punch.data = nil
        Punch.data.should == YAML.load(@data)
      end
    end
  end
  
  it 'should reset itself' do
    Punch.should respond_to(:reset)
  end
  
  describe 'when resetting itself' do
    before :each do
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
    end
    
    it 'should set its data to nil' do
      Punch.data = { 'proj' => 'lots of stuff here' }
      Punch.reset
      Punch.instance_variable_get('@data').should be_nil
    end
  end
  
  it 'should write data' do
    Punch.should respond_to(:write)
  end
  
  describe 'when writing data' do
    before :each do
      @file = stub('file')
      File.stubs(:open).yields(@file)
      @data = { 'proj' => 'data goes here' }
      
      Punch.instance_eval do
        class << self
          public :data=
        end
      end
      Punch.data = @data
    end
    
    it 'should open the data file for writing' do
      File.expects(:open).with(File.expand_path('~/.punch.yml'), 'w')
      Punch.write
    end
    
    it 'should write the data to the file in YAML form' do
      @file.expects(:puts).with(@data.to_yaml)
      Punch.write
    end
  end
  
  it 'should give project status' do
    Punch.should respond_to(:status)
  end
  
  describe "giving a project's status" do
    before :each do
      @now = Time.now
      @projects = { 'out' => 'test-o', 'in' => 'testshank' }
      @data = { 
        @projects['out'] => [ { 'in' => @now, 'out' => @now + 12 } ],
        @projects['in']  => [ { 'in' => @now } ]
      }
      
      Punch.instance_eval do
        class << self
          public :data=
        end
      end
      Punch.data = @data
    end
    
    it 'should accept a project name' do
      lambda { Punch.status('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a project name' do
      lambda { Punch.status }.should_not raise_error(ArgumentError)
    end
    
    it "should return 'out' if the project is currently punched out" do
      Punch.status(@projects['out']).should == 'out'
    end
    
    it "should return 'in' if the project is currently punched in" do
      Punch.status(@projects['in']).should == 'in'
    end
    
    it 'should return nil if the project does not exist' do
      Punch.status('other project').should be_nil
    end
    
    it 'should return nil if the project has no time data' do
      project = 'empty project'
      @data[project] = []
      Punch.data = @data
      Punch.status(project).should be_nil
    end
    
    it 'should use the last time entry for the status' do
      @data[@projects['out']].unshift *[{ 'in' => @now - 100 }, { 'in' => @now - 90, 'out' => @now - 50 }]
      @data[@projects['in']].unshift  *[{ 'in' => @now - 100, 'out' => @now - 90 }, { 'in' => @now - 50 }]
      Punch.data = @data
      
      Punch.status(@projects['out']).should == 'out'
      Punch.status(@projects['in']).should  == 'in'
    end
    
    it 'should return the status of all projects if no project name given' do
      Punch.status.should == { @projects['out'] => 'out', @projects['in'] => 'in' }
    end
  end
  
  it 'should indicate whether a project is punched out' do
    Punch.should respond_to(:out?)
  end
  
  describe 'indicating whether a project is punched out' do
    before :each do
      @project = 'testola'
    end
    
    it 'should accept a project name' do
      lambda { Punch.out?('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a project name' do
      lambda { Punch.out? }.should raise_error(ArgumentError)
    end
        
    it "should get the project's status" do
      Punch.expects(:status).with(@project)
      Punch.out?(@project)
    end
    
    it "should return true if the project's status is 'out'" do
      Punch.stubs(:status).returns('out')
      Punch.out?(@project).should == true
    end
    
    it "should return false if the project's status is 'in'" do
      Punch.stubs(:status).returns('in')
      Punch.out?(@project).should == false
    end
    
    it "should return true if the project's status is nil" do
      Punch.stubs(:status).returns(nil)
      Punch.out?(@project).should == true
    end
  end
  
  it 'should indicate whether a project is punched in' do
    Punch.should respond_to(:in?)
  end
  
  describe 'indicating whether a project is punched in' do
    before :each do
      @project = 'testola'
    end
    
    it 'should accept a project name' do
      lambda { Punch.in?('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a project name' do
      lambda { Punch.in? }.should raise_error(ArgumentError)
    end
        
    it "should get the project's status" do
      Punch.expects(:status).with(@project)
      Punch.in?(@project)
    end
    
    it "should return false if the project's status is 'out'" do
      Punch.stubs(:status).returns('out')
      Punch.in?(@project).should == false
    end
    
    it "should return true if the project's status is 'in'" do
      Punch.stubs(:status).returns('in')
      Punch.in?(@project).should == true
    end
    
    it "should return false if the project's status is nil" do
      Punch.stubs(:status).returns(nil)
      Punch.in?(@project).should == false
    end
  end
  
  it 'should punch a project in' do
    Punch.should respond_to(:in)
  end
  
  describe 'punching a project in' do
    before :each do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @project = 'test project'
      @data = { @project => [ {'in' => @now - 50, 'out' => @now - 25} ] }
      
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      Punch.data = @data
    end
    
    it 'should accept a project name' do
      lambda { Punch.in('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a project name' do
      lambda { Punch.in }.should raise_error(ArgumentError)
    end
    
    it 'should accept options' do
      lambda { Punch.in('proj', :time => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    describe 'when the project is already punched in' do
      before :each do
        @data = { @project => [ {'in' => @now - 50, 'out' => @now - 25}, {'in' => @now - 5} ] }
        Punch.data = @data
      end
      
      it 'should not change the project data' do
        old_data = @data.dup
        Punch.in(@project)
        Punch.data.should == old_data
      end
      
      it 'should return false' do
        Punch.in(@project).should == false
      end
    end
    
    describe 'when the project is not already punched in' do
      it 'should add a time entry to the project data' do
        Punch.in(@project)
        Punch.data[@project].length.should == 2
      end
      
      it 'should use now for the punch-in time' do
        Punch.in(@project)
        Punch.data[@project].last['in'].should == @now
      end
      
      it 'should log a message about punch-in time' do
        time = @now.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@project, "punch in @ #{time}")
        Punch.in(@project)
      end
      
      it 'should use a different time if given' do
        time = @now + 50
        Punch.in(@project, :time => time)
        Punch.data[@project].last['in'].should == time
      end
      
      it 'should log a message using the given time' do
        time = @now + 75
        time_str = time.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@project, "punch in @ #{time_str}")
        Punch.in(@project, :time => time)
      end
      
      it 'should log an additional message if given' do
        Punch.stubs(:log)  # for the time-based message
        message = 'working on some stuff'
        Punch.expects(:log).with(@project, message)
        Punch.in(@project, :message => message)
      end
      
      it "should allow the different time to be specified using :at" do
        time = @now + 50
        Punch.in(@project, :at => time)
        Punch.data[@project].last['in'].should == time
      end
      
      it 'should return true' do
        Punch.in(@project).should == true
      end
    end
    
    describe 'when the project does not yet exist' do
      before :each do
        @project = 'non-existent project'
      end
      
      it 'should create the project' do
        Punch.in(@project)
        Punch.data.should have_key(@project)
      end
      
      it 'should add a time entry to the project data' do
        Punch.in(@project)
        Punch.data[@project].length.should == 1
      end
      
      it 'should use now for the punch-in time' do
        Punch.in(@project)
        Punch.data[@project].last['in'].should == @now
      end
      
      it 'should log a message about punch-in time' do
        time = @now.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@project, "punch in @ #{time}")
        Punch.in(@project)
      end
      
      it 'should use a different time if given' do
        time = @now + 50
        Punch.in(@project, :time => time)
        Punch.data[@project].last['in'].should == time
      end
      
      it 'should log a message using the given time' do
        time = @now + 75
        time_str = time.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@project, "punch in @ #{time_str}")
        Punch.in(@project, :time => time)
      end
      
      it 'should return true' do
        Punch.in(@project).should == true
      end
    end
  end
  
  it 'should punch a project out' do
    Punch.should respond_to(:out)
  end
  
  describe 'punching a project out' do
    before :each do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @project = 'test project'
      @data = { @project => [ {'in' => @now - 50, 'out' => @now - 25} ] }
      
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      Punch.data = @data
    end
    
    it 'should accept a project name' do
      lambda { Punch.out('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a project name' do
      lambda { Punch.out }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept a project name and options' do
      lambda { Punch.out('proj', :time => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept options without a project name' do
      lambda { Punch.out(:time => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    describe 'when the project is already punched out' do
      it 'should not change the project data' do
        old_data = @data.dup
        Punch.out(@project)
        Punch.data.should == old_data
      end
      
      it 'should return false' do
        Punch.out(@project).should == false
      end
    end
    
    describe 'when the project is not already punched out' do
      before :each do
        @data = { @project => [ {'in' => @now - 50} ] }
        Punch.data = @data
      end
      
      it 'should not add a time entry to the project data' do
        Punch.out(@project)
        Punch.data[@project].length.should == 1
      end
      
      it 'should use now for the punch-out time' do
        Punch.out(@project)
        Punch.data[@project].last['out'].should == @now
      end
      
      it 'should log a message about punch-out time' do
        time = @now.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@project, "punch out @ #{time}")
        Punch.out(@project)
      end
      
      it 'should use a different time if given' do
        time = @now + 50
        Punch.out(@project, :time => time)
        Punch.data[@project].last['out'].should == time
      end
      
      it 'should log a message using the given time' do
        time = @now + 75
        time_str = time.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@project, "punch out @ #{time_str}")
        Punch.out(@project, :time => time)
      end
      
      it 'should log an additional message if given' do
        Punch.stubs(:log)  # for the time-based message
        message = 'finished working on some stuff'
        Punch.expects(:log).with(@project, message)
        Punch.out(@project, :message => message)
      end
      
      it "should allow the different time to be specified using :at" do
        time = @now + 50
        Punch.out(@project, :at => time)
        Punch.data[@project].last['out'].should == time
      end
      
      it 'should return true' do
        Punch.out(@project).should == true
      end
    end
    
    describe 'when no project is given' do
      before :each do
        @projects = ['test project', 'out project', 'other project']
        @data = {
          @projects[0] => [ {'in' => @now - 50, 'out' => @now - 25} ],
          @projects[1] => [ {'in' => @now - 300, 'out' => @now - 250}, {'in' => @now - 40} ],
          @projects[2] => [ {'in' => @now - 50} ],
        }
        Punch.data = @data
      end
      
      it 'should punch out all projects that are currently punched in' do
        Punch.out
        Punch.data[@projects[0]].last['out'].should == @now - 25
        Punch.data[@projects[1]].last['out'].should == @now
        Punch.data[@projects[2]].last['out'].should == @now
      end
      
      it 'should log punch-out messages for all projects being punched out' do
        time = @now.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@projects[1], "punch out @ #{time}")
        Punch.expects(:log).with(@projects[2], "punch out @ #{time}")
        Punch.out
      end
      
      it 'should use a different time if given' do
        time = @now + 50
        Punch.out(:time => time)
        Punch.data[@projects[0]].last['out'].should == @now - 25
        Punch.data[@projects[1]].last['out'].should == time
        Punch.data[@projects[2]].last['out'].should == time
      end
      
      it 'should log messages using the given time' do
        time = @now + 75
        time_str = time.strftime('%Y-%m-%dT%H:%M:%S%z')
        Punch.expects(:log).with(@projects[1], "punch out @ #{time_str}")
        Punch.expects(:log).with(@projects[2], "punch out @ #{time_str}")
        Punch.out(:time => time)
      end
      
      it 'should log an additional message if given' do
        Punch.stubs(:log)  # for the time-based messages
        message = 'finished working on some stuff'
        Punch.expects(:log).with(@projects[1], message)
        Punch.expects(:log).with(@projects[2], message)
        Punch.out(:message => message)
      end
      
      it 'should return true' do
        Punch.out.should == true
      end
      
      describe 'when all projects were already punched out' do
        before :each do
          @projects = ['test project', 'out project', 'other project']
          @data = {
            @projects[0] => [ {'in' => @now - 50, 'out' => @now - 25} ],
            @projects[1] => [ {'in' => @now - 300, 'out' => @now - 250}, {'in' => @now - 40, 'out' => @now - 20} ],
            @projects[2] => [ {'in' => @now - 50, 'out' => @now - 35} ],
          }
          Punch.data = @data
        end
        
        it 'should not change the data' do
          old_data = @data.dup
          Punch.out
          Punch.data.should == old_data
        end
        
        it 'should return false' do
          Punch.out.should == false
        end
      end
    end
  end

  it 'should delete a project' do
    Punch.should respond_to(:delete)
  end
  
  describe 'deleting a project' do
    before :each do
      @now = Time.now
      @project = 'test project'
      @data = { @project => [ {'in' => @now - 50, 'out' => @now - 25} ] }
      
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      Punch.data = @data
    end
    
    it 'should accept a project name' do
      lambda { Punch.delete('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a project name' do
      lambda { Punch.delete }.should raise_error(ArgumentError)
    end
    
    describe 'when the project exists' do
      it 'should remove the project data' do
        Punch.delete(@project)
        Punch.data.should_not have_key(@project)
      end
      
      it 'should return true' do
        Punch.delete(@project).should == true
      end
    end
    
    describe 'when the project does not exist' do
      before :each do
        @project = 'non-existent project'
      end
      
      it 'should return nil' do
        Punch.delete(@project).should be_nil
      end
    end
  end
  
  it 'should list project data' do
    Punch.should respond_to(:list)
  end
  
  describe 'listing project data' do
    before :each do
      @now = Time.now
      @project = 'test project'
      @data = { @project => [ {'in' => @now - 5000, 'out' => @now - 2500}, {'in' => @now - 2000, 'out' => @now - 1000}, {'in' => @now - 500, 'out' => @now - 100} ] }
      
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      Punch.data = @data
    end
    
    it 'should accept a project name' do
      lambda { Punch.list('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a project name' do
      lambda { Punch.list }.should_not raise_error(ArgumentError)
    end
    
    it 'should allow options' do
      lambda { Punch.list('proj', :after => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    describe 'when the project exists' do
      it 'should return the project data' do
        Punch.list(@project).should == Punch.data[@project]
      end
      
      it 'should restrict returned data to times only after a certain time' do
        Punch.list(@project, :after => @now - 501).should == Punch.data[@project].last(1)
      end
      
      it 'should restrict returned data to times only before a certain time' do
        Punch.list(@project, :before => @now - 2499).should == Punch.data[@project].first(1)
      end
      
      it 'should restrict returned data to times only within a time range' do
        Punch.list(@project, :after => @now - 2001, :before => @now - 999).should == Punch.data[@project][1, 1]
      end
      
      describe 'and is punched in' do
        before :each do
          @data[@project].push({ 'in' => @now - 25 })
          Punch.data = @data
        end
        
        it 'should restrict returned data to times only after a certain time' do
          Punch.list(@project, :after => @now - 501).should == Punch.data[@project].last(2)
        end

        it 'should restrict returned data to times only before a certain time' do
          Punch.list(@project, :before => @now - 2499).should == Punch.data[@project].first(1)
        end

        it 'should restrict returned data to times only within a time range' do
          Punch.list(@project, :after => @now - 2001, :before => @now - 999).should == Punch.data[@project][1, 1]
        end
      end
    end

    describe 'when the project does not exist' do
      before :each do
        @project = 'non-existent project'
      end
      
      it 'should return nil' do
        Punch.list(@project).should be_nil
      end
      
      it 'should return nil if options given' do
        Punch.list(@project, :after => @now - 500).should be_nil
      end
    end
    
    describe 'when no project is given' do
      before :each do
        @projects = ['test project', 'out project', 'other project']
        @data = {
          @projects[0] => [ {'in' => @now - 50, 'out' => @now - 25} ],
          @projects[1] => [ {'in' => @now - 300, 'out' => @now - 250}, {'in' => @now - 40, 'out' => @now - 20} ],
          @projects[2] => [ {'in' => @now - 50, 'out' => @now - 35} ],
        }
        Punch.data = @data
      end
      
      it 'should return data for all projects' do
        Punch.list.should == @data
      end
      
      it 'should respect options' do
        Punch.list(:after => @now - 51).should == { @projects[0] => @data[@projects[0]], @projects[1] => @data[@projects[1]].last(1), @projects[2] => @data[@projects[2]]}
      end
      
      it 'should not change the stored data when options are given' do
        old_data = @data.dup
        Punch.list(:after => @now - 51)
        Punch.data.should == old_data
      end
    end
  end

  it 'should get the total time for a project' do
    Punch.should respond_to(:total)
  end
  
  describe 'getting total time for a project' do
    before :each do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @project = 'test project'
      @data = { @project => [ {'in' => @now - 5000, 'out' => @now - 2500}, {'in' => @now - 2000, 'out' => @now - 1000}, {'in' => @now - 500, 'out' => @now - 100} ] }
      
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      Punch.data = @data
    end
    
    it 'should accept a project name' do
      lambda { Punch.total('proj') }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require a project name' do
      lambda { Punch.total }.should_not raise_error(ArgumentError)
    end
    
    it 'should allow options' do
      lambda { Punch.total('proj', :after => Time.now) }.should_not raise_error(ArgumentError)
    end
    
    describe 'when the project exists' do
      it 'should return the amount of time spent on the project (in seconds)' do
        Punch.total(@project).should == 3900
      end
      
      it 'should restrict returned amount to times only after a certain time' do
        Punch.total(@project, :after => @now - 501).should == 400
      end
      
      it 'should restrict returned amount to times only before a certain time' do
        Punch.total(@project, :before => @now - 2499).should == 2500
      end
      
      it 'should restrict returned amount to times only within a time range' do
        Punch.total(@project, :after => @now - 2001, :before => @now - 999).should == 1000
      end
      
      it 'should format the time spent if passed a format option' do
        Punch.total(@project, :format => true).should == "1:05:00"
      end
      
      describe 'and is punched in' do
        before :each do
          @data[@project].push({ 'in' => @now - 25 })
          Punch.data = @data
        end
        
        it 'give the time spent until now' do
          Punch.total(@project).should == 3925
        end
        
        it 'should restrict returned amount to times only after a certain time' do
          Punch.total(@project, :after => @now - 501).should == 425
        end

        it 'should restrict returned amount to times only before a certain time' do
          Punch.total(@project, :before => @now - 2499).should == 2500
        end

        it 'should restrict returned amount to times only within a time range' do
          Punch.total(@project, :after => @now - 2001, :before => @now - 999).should == 1000
        end
      end
    end

    describe 'when the project does not exist' do
      before :each do
        @project = 'non-existent project'
      end
      
      it 'should return nil' do
        Punch.total(@project).should be_nil
      end
    end
    
    describe 'when no project is given' do
      before :each do
        @projects = ['test project', 'out project', 'other project']
        @data = {
          @projects[0] => [ {'in' => @now - 50, 'out' => @now - 25} ],
          @projects[1] => [ {'in' => @now - 300, 'out' => @now - 250}, {'in' => @now - 40, 'out' => @now - 20} ],
          @projects[2] => [ {'in' => @now - 50, 'out' => @now - 35} ],
        }
        Punch.data = @data
      end
      
      it 'should give totals for all projects' do
        Punch.total.should == { @projects[0] => 25, @projects[1] => 70, @projects[2] => 15}
      end
      
      it 'should respect options' do
        Punch.total(:after => @now - 51).should == { @projects[0] => 25, @projects[1] => 20, @projects[2] => 15}
      end
      
      it 'should format the time spent if passed a format option' do
        Punch.total(:format => true).should == { @projects[0] => "00:25", @projects[1] => "01:10", @projects[2] => "00:15"}
      end
    end
  end
  
  it 'should log information about a project' do
    Punch.should respond_to(:log)
  end
  
  describe 'logging information about a project' do
    before :each do
      @now = Time.now
      @project = 'test project'
      @data = { @project => [ {'in' => @now - 50, 'log' => ['some earlier message']} ] }
      
      Punch.instance_eval do
        class << self
          public :data, :data=
        end
      end
      Punch.data = @data
      
      @message = 'some log message'
    end
    
    it 'should accept a project and message' do
      lambda { Punch.log('proj', 'some mess') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a message' do
      lambda { Punch.log('proj') }.should raise_error(ArgumentError)
    end
    
    it 'should require a project' do
      lambda { Punch.log }.should raise_error(ArgumentError)
    end
    
    it 'should check if the project is punched in' do
      Punch.expects(:in?).with(@project)
      Punch.log(@project, @message)
    end
    
    describe 'when the project is punched in' do
      it 'should add a log message to the last time entry for the project' do
        Punch.log(@project, @message)
        Punch.data[@project].last['log'].length.should == 2
      end
      
      it 'should use the given message for the log' do
        Punch.log(@project, @message)
        Punch.data[@project].last['log'].last.should == @message
      end
      
      it 'should return true' do
        Punch.log(@project, @message).should == true
      end
      
      describe 'and has no log' do
        before :each do
          @data = { @project => [ {'in' => @now - 50} ] }
          Punch.data = @data
        end
        
        it 'should create the log' do
          Punch.log(@project, @message)
          Punch.data[@project].last['log'].should == [@message]
        end
      end
    end
    
    describe 'when the project is not punched in' do
      before :each do
        @data = { @project => [ {'in' => @now - 50, 'out' => @now - 25, 'log' => ['some earlier message']} ] }
        Punch.data = @data
      end
      
      it 'should not change the project data' do
        old_data = @data.dup
        Punch.log(@project, @message)
        Punch.data.should == old_data
      end
      
      it 'should return false' do
        Punch.log(@project, @message).should == false
      end
    end
  end
end
