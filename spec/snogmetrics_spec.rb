require File.expand_path('../spec_helper', __FILE__)


module Rails
  def self.env
    self
  end
  
  def self.production?
    false
  end
end


describe Snogmetrics do
  
  before do
    @session = {}
    @context = Object.new
    @context.extend(Snogmetrics)
    @context.extend(ERB::Util)
    @context.stub!(:session).and_return(@session)
    @context.stub!(:kissmetrics_api_key).and_return('abc123')
  end
  
  describe '#km_record' do
    it 'will output a call to KM.record with with name and properties' do
      @context.km_record('hello world', :foo => 'bar')
      @context.km_js.should include('KM.record("hello world", {"foo":"bar"});')
    end
    
    it 'will output a call to KM.record with name only' do
      @context.km_record('foo')
      @context.km_js.should include('KM.record("foo");')
    end
    
    it 'will output a call to KM.record with properties only' do
      @context.km_record({:foo => 'bar', :plink => :plonk})
      # the order of the properties has is non-deterministic so we can't
      # test for the whole call, just fragments
      @context.km_js.should include('KM.record')
      @context.km_js.should include('"foo":"bar"')
      @context.km_js.should include('"plink":"plonk"')
    end
    
    it 'complains if called without arguments' do
      running { @context.km_record }.should raise_error
    end
    
    it 'complains if called with more than two arguments' do
      running { @context.km_record(1, 2, 3) }.should raise_error
    end
    
    it 'will output events with the same name in the order they were recorded' do
      @context.km_record('An important event', :p => 3)
      @context.km_record('An important event', :p => 4)
      js = @context.km_js
      js.should include('KM.record("An important event", {"p":"3"});')
      js.should include('KM.record("An important event", {"p":"4"});')
      js.index('KM.record("An important event", {"p":"3"});').should < js.index('KM.record("An important event", {"p":"4"});')
    end
  end
  
  describe '#km_identify' do
    it 'will output a call to KM.identify with the provided identity' do
      @context.km_identify('Phil')
      @context.km_js.should include('KM.identify("Phil");')
    end
    
    it 'will only output the last identity set' do
      @context.km_identify('Phil')
      @context.km_identify('Anne')
      @context.km_identify('Steve')
      @context.km_js.should_not include('Phil')
      @context.km_js.should_not include('Anne')
      @context.km_js.should     include('Steve')
    end
  end
  
  describe '#km_js' do
    it 'outputs nothing if there are no events and no identity' do
      @context.km_js.should be_empty
    end
    
    context 'in production' do
      before do
        Rails.stub!(:env).and_return(mock('env', :production? => true))
      end
      
      it 'outputs a JavaScript tag that loads the KISSmetrics API' do
        @context.km_identify('Phil')
        @context.km_js.should include('<script type="text/javascript" src="http://scripts.kissmetrics.com/t.js"></script>')
      end
    end
    
    context 'in non-production environments' do
      it 'outputs a JavaScript tag that mocks the KISSmetrics API' do
        @context.km_identify('Phil')
        @context.km_js.should include('var KM =')
      end
    end
    
    
    it 'outputs code that sets the KISSmetrics API key' do
      @context.km_identify('Phil')
      @context.km_js.should include('var KM_KEY = "abc123";')
    end
        
    it 'outputs a KM.record for every #km_record call' do
      @context.km_record('1')
      @context.km_record('2')
      @context.km_record('3')
      @context.km_js.scan(/KM\.record\("\d"\)/).size.should == 3
    end
    
    it 'resets the session when passed :reset => true' do
      @context.km_record('hello world')
      @context.km_js(:reset => true)
      @context.km_js.should be_empty
    end
  end
  
  describe '#km_js!' do
    it 'works like km_js(:reset => true)' do
      @context.km_record('hello world')
      @context.km_js!
      @context.km_js.should be_empty
    end
    
    it 'does not output any call to KM.identify if the identity has already been sent once' do
      @context.km_identify('Steve')
      @context.km_js!
      @context.km_identify('Steve')
      @context.km_js!.should_not include('KM.identify')
    end
    
    it 'ouputs a new call to KM.identify if #km_identify is called with a new identity' do
      @context.km_identify('Steve')
      @context.km_js!
      @context.km_identify('Anne')
      @context.km_js!.should include('KM.identify("Anne")')
    end
  end
  
end
