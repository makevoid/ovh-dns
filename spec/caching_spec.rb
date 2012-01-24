require_relative "../lib/caching"

PATH = File.expand_path "../../", __FILE__

class Stub

  def initialize
    @agent = agent
  end
  
  attr_accessor :loaded, :saved

  def agent
    obj = Object.new
    def obj.cookie_jar
      ob = Object.new
      def ob.load(object)
      end
      def ob.save_as(object)
        path = "#{PATH}/tmp/cookies/test.yml"
        File.open(path, "w") { |f| f.write "" }
      end
      ob
    end
    obj
  end
  
  include Caching
end

describe Caching do
  let(:klass) { Stub.new }
  
  it "is includable" do
    klass.should respond_to(:cache_object)
    klass.should respond_to(:cache_cookies)
  end
  
  it "caches object" do
    obj = klass.cache_object(:test) { "TEST" }
    obj.should == "TEST"
    obj = klass.cache_object(:test) { "TEST1" }
    obj.should == "TEST"
  end
  
  it "caches cookies" do
    guard = nil
    klass.cache_cookies(:test) { guard = "changed" }
    guard.should == "changed"
    klass.cache_cookies(:test) { guard = "changed again" }
    guard.should == "changed"    
  end
  
  it "clear cached cookies" do
    klass.cache_clear :cookies, :test
    file = klass.cache_path  :cookies, :test
    File.exist?(file).should_not be_true
    
    klass.cache_clear :objects, :test
    file = klass.cache_path  :objects, :test
    File.exist?(file).should_not be_true    
  end
end