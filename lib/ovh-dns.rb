PATH = File.expand_path "../../", __FILE__


module Ovh

  class DNS
    require 'mechanize'
    
    USER = "cf40475-ovh"
    PASS = File.read File.expand_path("~/.password")
  
    LOGIN_URL = "https://www.ovh.it/managerv3/login.pl?xsldoc=&domain=accademiacappiello.it&language=it"
    HOME_URL = "https://www.ovh.it/managerv3/home.pl"
    
    attr_reader :agent
    
    require_relative "caching"
    include Caching
    
    class Domain

      def initialize(name)
        @name = name
      end

    end    
        
    class Record
      
      # { name: "asd", type: "MX", dest: "asd.com", priority: 1 }
      def initialize(hash)
        @name = hash[:name]
        @type = hash[:type]
        @dest = hash[:dest]
        @priority = hash[:priority]
      end
      
    end
    
    def records_url(domain)
       "https://www.ovh.it/managerv3/hosting-domain-zone.pl?xsldoc=hosting%2Fdomain%2Fhosting-domain-zone.xsl&language=it&domain=#{domain}&lastxsldoc=hosting%2Fdomain%2Fhosting-domain.xsl&csid=0"
    end
  
    def initialize
      @agent = Mechanize.new
      @agent.user_agent = "Mac Safari"
      login
      start_logger
    end
  
    private
    
    def open_in_safari
      file = "#{PATH}/tmp/pages/index.html"
      File.open(file, "w") { |f| f.write @agent.page.body }
      `open #{file}`
    end
  
    def login
      cache_cookies :login do
        page = @agent.get LOGIN_URL
        form = page.forms.first
        form.session_nic = USER
        form.session_password = PASS
        form.submit
      end
    end
  
    def start_logger
      require "logger"
      # @agent.log = Logger.new(STDOUT)
    end
  
    # 
    public
  
    def each_domain
      domains.each do |domain|
        yield(domain)
      end
    end
  
    def domains
      cache_object :domains do 
        page = @agent.get HOME_URL
        # open_in_safari
        options = page.search "#domainSelect optgroup[label='servizi di hosting'] option"
        options.map do |option|
          option.text
        end
      end
    end
  
    def records(domain)
      page = @agent.get records_url(domain)
      records = []
      page.search("table.actionTable tr")[1..-2].each do |tr|
        tds = tr.search("td")
        record, type, dest = tds[1..3].map{ |t| t.inner_text }
        records << { record: record, type: type, dest: dest }
      end
      records
    end
    
  end
end



# domain = "accademiacappiello.it"
# p ovh.records(domain)
# 
# domain = "fivetastic.org"
# p ovh.records(domain)








# GET /domains

# Hosting e domini

# POST /record
#https://www.ovh.it/managerv3/hosting-domain-zone.pl?xsldoc=hosting%2Fdomain%2Fhosting-domain-zone.xsl&language=it&domain=accademiacappiello.it


record = { name: "asd", type: "MX", dest: "asd.com", priority: 1 }

def add_url(type)   "https://www.ovh.it/managerv3/hosting-domain-zone.pl?xsldoc=hosting%2Fdomain%2Fhosting-domain-zone-#{type}-create.xsl&language=it&domain=accademiacappiello.it"
end

POST_URL = "https://www.ovh.it/managerv3/hosting-domain-zone.pl"


# class Record


def add(record) # POST /record
  url = add_url(record[:type])
  page = @agent.get url
  form = page.forms.first
  form.subdomain = record[:name]
  form.priority = record[:priority]
  form.target = record[:dest]
  page = form.submit
end


def delete(record) # DELETE /record
  post = { subdomain: record, target: dest, editMxAnyway: 1, fieldtype: "#{type} #{priority}", language: "it", domain: "accademiacappiello.it", position: 0, todo: "DnsEntryDelete",  csid: 0, xsldoc: "hosting/domain/hosting-domain-zone.xsl", xsldoc: "hosting/domain/hosting-domain-zone.xsl", hostname: "accademiacappiello.it", service: "accademiacappiello.it"}
  @agent.post POST_URL, post  
end



# add record


# priority = 1
# delete record, type, dest, priority



#page agent.get 

