require_relative "../lib/ovh-dns"

describe Ovh::DNS do
  
  specify { should be_a(Ovh::DNS) }
  
  it "logins" do
    dns = Ovh::DNS.new
    jar = dns.agent.cookie_jar.jar
    jar.should_not == {}
    jar["www.ovh.it"].should_not == {}
    jar["ovh.it"].should_not == {}
  end
  
  it "lists domains" do
    dns = Ovh::DNS.new
    domains = dns.domains
    domains.should be_an(Array)
    domains.length.should > 1
  end
  

  it "lists domain records"
  
  pending "adds a dns record"
  pending "deletes a dns record"
  pending "iterates on all domains"

  after :all do
    FileUtils.rm_f "#{PATH}/tmp/cookies/login.yml"
    FileUtils.rm_f "#{PATH}/tmp/objects/domains.dump"
  end

end