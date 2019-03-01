require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe Integer do
  it 'should give an elapsed time' do
    50.should.respond_to(:elapsed_time)
  end

  describe 'giving an elapsed time' do
    it 'should convert the number as seconds to an HH:MM:SS format' do
      60174.elapsed_time.should == '16:42:54'
    end

    it 'should format seconds as two digits' do
      135182.elapsed_time.should == '37:33:02'
    end

    it 'should format minutes as two digits' do
      39900.elapsed_time.should == '11:05:00'
    end

    it 'should not format hours as two digits' do
      3900.elapsed_time.should == '1:05:00'
    end

    it 'should not includes hours if the time is less than an hour' do
      890.elapsed_time.should == '14:50'
    end
  end
end
