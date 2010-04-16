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
    @context.stub!(:session).and_return(@session)
    @context.stub!(:kissmetrics_api_key).and_return('abc123')
  end
  
  describe '#record' do
    it 'will output code that pushes an event with the specified name and properties' do
      @context.km.record('hello world', :foo => 'bar')
      @context.km.js.should include('_kmq.push(["record","hello world",{"foo":"bar"}]);')
    end
    
    it 'will output code that pushes an event with name only' do
      @context.km.record('foo')
      @context.km.js.should include('_kmq.push(["record","foo"]);')
    end
    
    it 'will output code that pushes an event with properties only' do
      @context.km.record({:foo => 'bar', :plink => :plonk})
      @context.km.js.should match(%r#_kmq.push\(\["record",\{(?:"foo":"bar","plink":"plonk"|"plink":"plonk","foo":"bar")\}\]\)#)
    end
    
    it 'complains if called without arguments' do
      running { @context.km.record }.should raise_error
    end
    
    it 'complains if called with more than two arguments' do
      running { @context.km.record(1, 2, 3) }.should raise_error
    end
    
    it 'will output code that pushes events with the same name in the order they were recorded' do
      @context.km.record('An important event', :p => 3)
      @context.km.record('An important event', :p => 4)
      js = @context.km.js
      first = '_kmq.push(["record","An important event",{"p":3}]);'
      second = '_kmq.push(["record","An important event",{"p":4}]);'
      js.should include(first)
      js.should include(second)
      js.index(first).should < js.index(second)
    end
  end
  
  describe '#identify' do
    it 'will output code that pushes an identify call with the provided identity' do
      @context.km.identify('Phil')
      @context.km.js.should include('_kmq.push(["identify","Phil"]);')
    end
    
    it 'will only output the last identity set' do
      @context.km.identify('Phil')
      @context.km.identify('Anne')
      @context.km.identify('Steve')
      @context.km.js.should_not include('Phil')
      @context.km.js.should_not include('Anne')
      @context.km.js.should     include('Steve')
    end
  end
  
  describe '#set' do
    it 'will output code that pushes a set call with the provided experiment name and variant' do
      @context.km.set('My Awesome Experiment', 'variant_a')
      @context.km.js.should include('_kmq.push(["set","My Awesome Experiment","variant_a"])')
    end
  end
  
  describe '#js' do
    it 'outputs nothing if there are no events and no identity' do
      @context.km.js.should be_empty
    end
    
    context 'in production' do
      before do
        Rails.stub!(:env).and_return(mock('env', :production? => true))
      end
      
      it 'outputs a JavaScript tag that loads the KISSmetrics API for the provided API key' do
        @context.stub!(:kissmetrics_api_key).and_return('cab1ebeef')
        @context.km.identify('Phil')
        @context.km.js.should include('scripts.kissmetrics.com/cab1ebeef.1.js')
      end
    end
    
    context 'overriding #use_fake_kissmetrics_api?' do
      it 'will do your bidding, and not be influenced by Rails.env' do
        Rails.stub!(:env).and_return(mock('env', :production? => true))
        @context.stub!(:use_fake_kissmetrics_api?).and_return(true)
        @context.km.identify('Joyce')
        @context.km.js.should_not include('scripts.kissmetrics.com')
      end
    end
    
    it 'outputs code that conditionally sets the _kmq variable' do
      @context.km.identify('Phil')
      @context.km.js.should include('var _kmq = _kmq || [];')
    end
        
    it 'outputs code that pushes an event for every #record call' do
      @context.km.record('1')
      @context.km.record('2')
      @context.km.record('3')
      @context.km.js.scan(/_kmq.push\(\["record","\d"\]\)/).should have(3).items
    end
    
    it 'resets the session when passed :reset => true' do
      @context.km.record('hello world')
      @context.km.js(:reset => true)
      @context.km.js.should be_empty
    end
    
    it 'does not let HTML slip through' do
      @context.km.identify('</html>')
      @context.km.js.should_not include('</html>')
    end
  end
  
  describe '#js!' do
    it 'works like #js(:reset => true)' do
      @context.km.record('hello world')
      @context.km.js!
      @context.km.js.should be_empty
    end
    
    it 'does not push an identify call if the identity has already been sent once' do
      @context.km.identify('Steve')
      @context.km.js!
      @context.km.identify('Steve')
      @context.km.js!.should_not include('_kmq.push(["identify"')
    end
    
    it 'ouputs code that pushes an identify call if #identify is called with a new identity' do
      @context.km.identify('Steve')
      @context.km.js!
      @context.km.identify('Anne')
      @context.km.js!.should include('_kmq.push(["identify","Anne"])')
    end
  end
  
end
