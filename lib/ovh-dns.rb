PATH = File.expand_path "../../", __FILE__


module Ovh

  class DNS
    require 'mechanize'
    
    USER = "cf40475-ovh"
    PASS = File.read File.expand_path("~/.password")
    
    HOST = "https://www.ovh.it"
    LOGIN_URL = "#{HOST}/managerv3/login.pl?xsldoc=&domain=accademiacappiello.it&language=it"
    HOME_URL = "#{HOST}/managerv3/home.pl"
    POST_URL = "#{HOST}/managerv3/hosting-domain-zone.pl"
    
    attr_reader :agent
    
    require_relative "caching"
    include Caching
    
    class Domain
      include Caching

      attr_reader :name
      attr_accessor :records
      
      def initialize(name)
        @name = name
      end
      
      def records
        @records = cache_object "domain_#{@name}_records" do
          agent = Agent.instance
          page = agent.get records_url(@name)
          page = clear_cookies_unless_logged(page) do
            agent.get records_url(@name)
          end
          records = []
          page.search("table.actionTable tr")[1..-2].each do |tr|
            tds = tr.search("td")
            record, type, dest = tds[1..3].map{ |t| t.inner_text }
            record = record.sub /\.#{@name.gsub ".", "\."}$/, ''
            records << { name: record, type: type, dest: dest }
          end
          records
        end
        @records = @records.map{ |rec| Record.new(rec) }
      end
      
      def add_record(record)
        Record.add(record, self)
      end
      
      private
      
      def logged?(page)
        page.search("body").text =~ /Password perduta\?/
      end
      
      def clear_cookies_unless_logged(page)
        if logged?(page)
          cache_clear :cookies, :login
          Ovh::DNS.new.agent
          yield
        else
          page
        end
      end
      
      def records_url(domain)
         "https://www.ovh.it/managerv3/hosting-domain-zone.pl?xsldoc=hosting%2Fdomain%2Fhosting-domain-zone.xsl&language=it&domain=#{domain}&lastxsldoc=hosting%2Fdomain%2Fhosting-domain.xsl&csid=0"
      end
      

    end    
        
    class Record
      
      attr_accessor :name, :type, :dest, :priority
      
      # { name: "asd", type: "MX", dest: "asd.com", priority: 1 }
      def initialize(hash)
        @name = hash[:name]
        @type = hash[:type]
        @dest = hash[:dest]
        @priority = hash[:priority]
      end
      
      def self.add(record, domain)
        agent = Agent.instance
        priority = record[:priority] || 1
        xsldoc = "hosting/domain/hosting-domain-zone.xsl"
        post = { subdomain: record[:name], target: record[:dest], fieldtype: "#{record[:type]} #{record[:priority]}".strip, todo: "DnsEntryAddCustom", plan: "CUSTOM", language: "it", domain: domain.name, priority: priority, csid: 0, xsldoc: xsldoc, lastxsldoc: xsldoc, hostname: domain.name, service: domain.name}
        page = agent.post POST_URL, post
        domain.cache_clear :objects, "domain_#{domain.name}_records"
        true
      end
      
      def delete
        agent = Agent.instance
        priority = @priority || 1
        xsldoc = "hosting/domain/hosting-domain-zone.xsl"
        post = { subdomain: @name, target: @dest, fieldtype: "#{@type} #{@priority}".strip, todo: "DnsEntryDelete", language: "it", domain: domain.name, priority: priority, csid: 0, xsldoc: xsldoc, lastxsldoc: xsldoc, hostname: domain.name, service: domain.name}
        p post
        page = agent.post POST_URL, post
        domain.cache_clear :objects, "domain_#{domain.name}_records"
        true
      end
      
    end
    
    class Agent 
      def self.instance
        unless defined?(@@agent)
          @@agent = Mechanize.new
          @@agent.user_agent = "Mac Safari"
          @@agent
        else
          @@agent
        end
      end

      def self.open_in_safari
        file = "#{PATH}/tmp/pages/index.html"
        File.open(file, "w") { |f| f.write instance.page.body }
        `open #{file}`        
      end
    end
    
    def agent
      Agent.instance
    end
  
    def initialize
      login
      start_logger
    end
  
    private
  
    def login
      cache_cookies :login do
        page = agent.get LOGIN_URL
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
        page = agent.get HOME_URL
        # open_in_safari
        options = page.search "#domainSelect optgroup[label='servizi di hosting'] option"
        options.map do |option|
          Domain.new option.text
        end
      end
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




# class Record


def add(record) # POST /record

end


def delete(record, dest, domain_name) # DELETE /record
  xsldoc = "hosting/domain/hosting-domain-zone.xsl"
  post = { subdomain: record, target: dest, editMxAnyway: 1, fieldtype: "#{type} #{priority}", language: "it", domain: domain_name, position: 0, todo: "DnsEntryDelete",  csid: 0, xsldoc: xsldoc, lastxsldoc: xsldoc, hostname: domain_name, service: domain_name}
  @agent.post POST_URL, post  
end





# add record


# priority = 1
# delete record, type, dest, priority



#page agent.get 

