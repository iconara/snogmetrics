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
    allow(@context).to receive(:session).and_return(@session)
  end

  describe '#record' do
    it 'will output code that pushes an event with the specified name and properties' do
      @context.km.record('hello world', foo: 'bar')
      expect(@context.km.js).to include('_kmq.push(["record","hello world",{"foo":"bar"}]);')
    end

    it 'will output code that pushes an event with name only' do
      @context.km.record('foo')
      expect(@context.km.js).to include('_kmq.push(["record","foo"]);')
    end

    it 'will output code that pushes an event with properties only' do
      @context.km.record(foo: 'bar', plink: :plonk)
      expect(@context.km.js).to match(/_kmq.push\(\["record",\{(?:"foo":"bar","plink":"plonk"|"plink":"plonk","foo":"bar")\}\]\)/)
    end

    it 'complains if called without arguments' do
      expect(running { @context.km.record }).to raise_error(RuntimeError, 'Not enough arguments')
    end

    it 'complains if called with more than two arguments' do
      expect(running { @context.km.record(1, 2, 3) }).to raise_error(RuntimeError, 'Too many arguments')
    end

    it 'will output code that pushes events with the same name in the order they were recorded' do
      @context.km.record('An important event', p: 3)
      @context.km.record('An important event', p: 4)
      js = @context.km.js
      first = '_kmq.push(["record","An important event",{"p":3}]);'
      second = '_kmq.push(["record","An important event",{"p":4}]);'
      expect(js).to include(first)
      expect(js).to include(second)
      expect(js.index(first)).to be < js.index(second)
    end
  end

  describe '#trackClick' do
    it 'will output code that pushes an event with the specified name and properties' do
      @context.km.trackClick('tagid', 'hello world', foo: 'bar')
      expect(@context.km.js).to include('_kmq.push(["trackClick","tagid","hello world",{"foo":"bar"}]);')
    end

    it 'will output code that pushes an event with name only' do
      @context.km.trackClick('tagid', 'foo')
      expect(@context.km.js).to include('_kmq.push(["trackClick","tagid","foo"]);')
    end

    it 'will output code that pushes an event with properties only' do
      @context.km.trackClick('tagid', foo: 'bar', plink: :plonk)
      expect(@context.km.js).to match(/_kmq.push\(\["trackClick","tagid",\{(?:"foo":"bar","plink":"plonk"|"plink":"plonk","foo":"bar")\}\]\)/)
    end

    it 'complains if called without arguments' do
      expect(running { @context.km.trackClick }).to raise_error(ArgumentError)
    end

    it 'complains if called with selector only' do
      expect(running { @context.km.trackClick('tagid') }).to raise_error(RuntimeError, 'Not enough arguments')
    end

    it 'complains if called with more than three arguments' do
      expect(running { @context.km.trackClick('tagid', 'hello world', { foo: 'bar' }, '12') }).to raise_error(RuntimeError, 'Too many arguments')
    end
  end

  describe '#identify' do
    it 'will output code that pushes an identify call with the provided identity' do
      @context.km.identify('Phil')
      expect(@context.km.js).to include('_kmq.push(["identify","Phil"]);')
    end

    it 'will only output the last identity set' do
      @context.km.identify('Phil')
      @context.km.identify('Anne')
      @context.km.identify('Steve')
      expect(@context.km.js).not_to include('Phil')
      expect(@context.km.js).not_to include('Anne')
      expect(@context.km.js).to     include('Steve')
    end
  end

  describe '#set' do
    it 'will output code that pushes a set call with the provided experiment name and variant' do
      @context.km.set('My Awesome Experiment', 'variant_a')
      expect(@context.km.js).to include('_kmq.push(["set",{"My Awesome Experiment":"variant_a"}])')
    end
  end

  describe '#js' do
    context 'in production' do
      before do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
      end

      it 'outputs a JavaScript tag that loads the KISSmetrics API for the provided API key' do
        Snogmetrics.kissmetrics_api_key = 'cab1ebeef'
        @context.km.identify('Phil')
        expect(@context.km.js).to include('scripts.kissmetrics.com/cab1ebeef.2.js')
      end
    end

    context 'overriding #use_fake_kissmetrics_api?' do
      it 'will do your bidding, and not be influenced by Rails.env' do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
        allow(@context).to receive(:use_fake_kissmetrics_api?).and_return(true)
        @context.km.identify('Joyce')
        expect(@context.km.js).not_to include('scripts.kissmetrics.com')
      end
    end

    context 'overriding #output_strategy with :console_log' do
      it 'outputs calls to console.log' do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
        allow(@context).to receive(:output_strategy).and_return(:console_log)
        @context.km.identify('Joyce')
        expect(@context.km.js).not_to include('scripts.kissmetrics.com')
        expect(@context.km.js).to include('console.dir')
      end

      it 'outputs calls to console.log when configured with accessor' do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
        Snogmetrics.output_strategy = :console_log
        @context.km.identify('Joyce')
        expect(@context.km.js).not_to include('scripts.kissmetrics.com')
        expect(@context.km.js).to include('console.dir')
      end
    end

    context 'overriding #output_strategy with :array' do
      it 'just stores calls in the _kmq array' do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
        allow(@context).to receive(:output_strategy).and_return(:array)
        @context.km.identify('Joyce')
        expect(@context.km.js).not_to include('scripts.kissmetrics.com')
        expect(@context.km.js).not_to include('console.dir')
      end

      it 'just stores calls in the _kmq array when configured with accessor' do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
        Snogmetrics.output_strategy = :array
        @context.km.identify('Joyce')
        expect(@context.km.js).not_to include('scripts.kissmetrics.com')
        expect(@context.km.js).not_to include('console.dir')
      end
    end

    context 'overriding #output_strategy with :live' do
      it 'sends calls to KISSmetrics' do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
        allow(@context).to receive(:output_strategy).and_return(:live)
        @context.km.identify('Joyce')
        expect(@context.km.js).to include('scripts.kissmetrics.com')
        expect(@context.km.js).not_to include('console.dir')
      end

      it 'sends calls to KISSmetrics when configured with accessor' do
        allow(Rails).to receive(:env).and_return(double('env', production?: true))
        Snogmetrics.output_strategy = :live
        @context.km.identify('Joyce')
        expect(@context.km.js).to include('scripts.kissmetrics.com')
        expect(@context.km.js).not_to include('console.dir')
      end
    end

    context 'overriding #output_strategy with something else' do
      it 'raises' do
        allow(@context).to receive(:output_strategy).and_return(:something_else)
        expect do
          expect(@context.km.js).to include('scripts.kissmetrics.com')
        end.to raise_error(RuntimeError, 'Unknown KISSmetrics output strategy: something_else')
      end
    end

    it 'outputs javascript even if there are no events and no identity' do
      expect(@context.km.js).to include('kmq')
    end

    it 'outputs code that conditionally sets the _kmq variable' do
      @context.km.identify('Phil')
      expect(@context.km.js).to include('var _kmq = _kmq || [];')
    end

    it 'outputs code that pushes an event for every #record call' do
      @context.km.record('1')
      @context.km.record('2')
      @context.km.record('3')
      expect(@context.km.js.scan(/_kmq.push\(\["record","\d"\]\)/).size).to eq(3)
    end

    it 'resets the session when passed :reset => true' do
      @context.km.record('hello world')
      @context.km.js(reset: true)
      expect(@context.km.js).not_to include('hello world')
    end

    it 'does not let HTML slip through' do
      @context.km.identify('</html>')
      expect(@context.km.js).not_to include('</html>')
    end
  end

  describe '#js!' do
    it 'works like #js(:reset => true)' do
      @context.km.record('hello world')
      @context.km.js!
      expect(@context.km.js!).not_to include('_kmq.push(["record"')
    end

    it 'does not push an identify call if the identity has already been sent once' do
      @context.km.identify('Steve')
      @context.km.js!
      @context.km.identify('Steve')
      expect(@context.km.js!).not_to include('_kmq.push(["identify"')
    end

    it 'ouputs code that pushes an identify call if #identify is called with a new identity' do
      @context.km.identify('Steve')
      @context.km.js!
      @context.km.identify('Anne')
      expect(@context.km.js!).to include('_kmq.push(["identify","Anne"])')
    end
  end
end
