PATH = File.expand_path "../", __FILE__
require 'ovh-rb'

USER = "cf40475-ovh"
PASS = File.read File.expand_path("~/.password")

path = "#{PATH}/db/ovh_session.rb"

OvhRb::Session.new USER, PASS do |session|
  # result1 = session.domain_info("whoisy.net")
  # File.open path, "w" do |file|
  #   file.write Marshal.dump(result1)
  # end
  
  # session = Marshal.load File.read(path)
  # result2 = session
  # # p result1
  # p result2
  
  result = session.domain_info("whoisy.net")
  p result
  
  result = session.domain_info("fivetastic.org")
  puts result
end