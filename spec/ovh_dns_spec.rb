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
  
  it "returns a list of domains" do
    dns = Ovh::DNS.new
    p dns.domains
  end
end