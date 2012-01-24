require_relative "../lib/ovh-dns"

dns = Ovh::DNS.new
domain = dns.domains.first
p domain.records #=> []

domain.add_record name: "makevoid.com", type: "A", dest: "176.31.248.215"
domain.add_record name: "mail.makevoid.com", type: "MX", dest: "176.31.248.215", priority: 1

domain.delete "mail.makevoid.com"
      
p domain.records #=> [{ name: "makevoid.com", type: "A", dest: "176.31.248.215" }]
  
dns.each_domain do |domain|
  p domain.records
end