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
    domains.first.should be_a(Ovh::DNS::Domain)
  end
  
  it "finds domain records" do
    dns = Ovh::DNS.new
    records = dns.domains.first.records
    records.should be_an(Array)
    records.first.should be_a(Ovh::DNS::Record)
  end
  
  it "adds a dns record" do
    dns = Ovh::DNS.new
    domain = dns.domains.first
    domain.add_record name: "antani", type: "A", dest: "94.23.210.6"
    record = domain.records.find do |record|
      record.name == "antani"
    end
    record.should be_a(Ovh::DNS::Record)
  end
  
  it "deletes a dns record" do
    dns = Ovh::DNS.new
    domain = dns.domains.first
    domain.add_record name: "antani", type: "A", dest: "94.23.210.6"
    record = domain.records.find do |record|
      record.name == "antani"
    end
    record.delete
  end
  pending "iterates on all domains"

  after :all do
    # FileUtils.rm_f "#{PATH}/tmp/cookies/login.yml"
    # FileUtils.rm_f "#{PATH}/tmp/objects/domains.dump"
  end

end