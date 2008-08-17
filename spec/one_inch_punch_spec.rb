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
        def data() @data; end
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
    end
    
    describe 'when no file is found' do
      before :each do
        File.stubs(:read).raises(Errno::ENOENT)
      end
      
      it 'should leave the data blank' do
        Punch.load
        Punch.data.should be_nil
      end
      
      it 'should return false' do
        Punch.load.should == false
      end
    end
  end
  
  it 'should reset itself' do
    Punch.should respond_to(:reset)
  end
  
  describe 'when resetting itself' do
    it 'should set its data to nil' do
      Punch.instance_variable_set('@data', {'proj' => 'lots of stuff here'})
      Punch.reset
      Punch.data.should be_nil
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
      Punch.instance_variable_set('@data', @data)
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
end
