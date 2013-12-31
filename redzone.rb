#! /usr/bin/env ruby

require 'yaml'
require 'tsort'

class String
  def unindent 
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end
module RedZone
  class ZoneConfig
    include TSort
    def initialize(zonefile)
      @cfg = YAML.load_file(zonefile)
      @zones = Hash.new {|h,k| h[k] = []}
      @machines = []
      @ips = []
      @cfg['zones'].each do |k,v|
        add(Zone.new(k,v))
      end
    end
    def add(zone)
      @zones[zone.name] = zone
    end
    def tsort_each_node(&block)
      @zones.each_key(&block)
    end
    def tsort_each_child(node, &block)
      @zones[node].dependencies.each(&block) if @zones.has_key?(node)
    end
    def domains
      d = []
      @zones.each do |k,v|
        d << v.domains
      end
      d.flatten
    end
    def setup!
      self.tsort.each do |z|
        zone = @zones[z]
        zone.dependencies.each do |dep|
          zone.inherit!(@zones[dep])
        end
      end
    end
    def generate_domain(domain) 
      io = StringIO.new
      @zones.each do |k,v|
        if v.domains.include?(domain)
          io << v.generate_zonefile(domain)
        end
      end
      io.string
    end
  end
  class Zone
    attr_reader :name,:dependencies,:config
    def inherit!(zone)
      unless @inherited.include?(zone.name)
        @config = zone.config.merge(@config)
        @inherited << zone.name
      end
    end
    def initialize(name,config)
      @inherited = []
      @name   = name
      @config = config
      @dependencies = []
      if @config.has_key?('inherits')
        @dependencies << @config['inherits']
        @dependencies = @dependencies.flatten
      end
    end
    def domains
      @config['domains'] || []
    end
    def generate_conffile(domain,datafile,masters=[])
      io = StringIO.new
      write_conffile(io,domain,datafile,masters)
      io.string
    end
    def write_conffile(io,domain,datafile,masters=[])
      if not masters.empty?
        masterlist = masters.join(" ; ")
        io << <<-eos.unindent
        zone "#{domain}" in {
          type slave;
          file "#{datafile}";
          masters { #{masterlist} ; } ;
        }
        eos
      else
        io << <<-eos.unindent
        zone "#{domain}" in {
          type master;
          file "#{datafile}";
        }
        eos
      end
    end
    def generate_zonefile(domain)
      io = StringIO.new
      write_zonefile(io,domain)
      io.string
    end
    def write_zonefile(io,domain)
      io << generate_soa(domain)
      io << generate_default
      io << generate_dns
      io << generate_mail
      io << generate_machines
      io << generate_names
      io << generate_aliases
      io << generate_wildcard
    end
    
    private
    def all_machines
      machines = []
      @config['machines'].each do |name,cfg|
        machines << Machine.new(name,cfg)
      end
      machines
    end
    def get_machine(name)
      Machine.new(name,@config['machines'][name])
    end
    def generate_soa(domain)
      lifetimes  = @config['lifetimes']
      ttl        = lifetimes['ttl']
      hostmaster = @config['hostmaster']
      now        = Time.now.to_i
      refresh    = lifetimes['refresh']
      re         = lifetimes['retry']
      expire     = lifetimes['expire']
      negative   = lifetimes['negative']
      <<-eos.unindent
      $ORIGIN  #{domain}.
      $TTL     #{ttl} ; queries are cached for this long
      @        IN    SOA    ns1    #{hostmaster} (
                     #{now} ; Date $time
                     #{refresh}  ; slave queries for refresh this often
                     #{re} ; slave retries refresh this often after failure
                     #{expire} ; slave expires after this long if not refreshed
                     #{negative} ; errors are cached for this long
      )
      
      eos
    end
    def generate_record(name,type,detail,value,comment=nil)
      suffix = " ; #{comment}" unless comment.nil?
      "%-20s IN    %-8s %-6s %s%s\n" % [name, type, detail, value, suffix || ""]
    end
    def generate_machine(name,machine)
      comment = "Machine #{machine}" unless name == machine
      if machine.is_a? String
        machine = get_machine(machine)
      end
      io = StringIO.new
      io << generate_record(name,"A","",machine.ipv4,comment) if machine.ipv4?
      io << generate_record(name,"AAAA","",machine.ipv6,comment) if machine.ipv6?
      io.string
    end
    def generate_default
      io = StringIO.new
      if @config['default']
        io <<  "; Primary name records for unqualfied domain\n"
        io << generate_machine("@",@config['default'])
        io << "\n"
      end
      io.string
    end
    def generate_dns
      io = StringIO.new
      if @config.has_key?('dns')
        io << ": DNS Server Records\n"
        dns_keys = @config['dns'].keys.sort
        dns_keys.each do |k|
          io << generate_record("@","NS","",k)
        end
        dns_keys.each do |k|
          machine = @config['dns'][k]
          io << generate_machine(k,machine)
        end
        io << "\n"
      end
      io.string
    end
    def generate_mail
      io = StringIO.new
      if @config.has_key?('mail')
        io << "; Email Servers\n"
        mail_keys = @config['mail'].keys.sort
        mail_keys.each do |k|
          mail = @config['mail'][k]
          priority = mail['priority']
          io << generate_record("@","MX",priority,k)
        end
        mail_keys.each do |k|
          mail = @config['mail'][k]
          machine = mail['machine']
          io << generate_machine(k,machine)
        end
        io << "\n"
      end
      io.string
    end
    def generate_machines 
      io = StringIO.new
      io << "; Primary Machine Names\n"
      all_machines.each do |machine|
        io << generate_machine(machine.name,machine)
      end
      io << "\n"
      io.string
    end
    def generate_names
      io = StringIO.new
      if @config.has_key?('mail')
        io << "; Extra Names\n"
        name_keys = @config['names'].keys.sort
        name_keys.each do |name|
          machine = @config['names'][name]
          io << generate_machine(name,machine)
        end
        io << "\n"
      end
      io.string
    end
    def generate_aliases
      io = StringIO.new
      if @config.has_key?('mail')
        io << "; Extra Names\n"
        cname_keys = @config['aliases'].keys.sort
        cname_keys.each do |cname|
          value = @config['aliases'][cname]
          io << generate_record(cname,"CNAME","",value)
        end
        io << "\n"
      end
      io.string
    end
    def generate_wildcard
      io = StringIO.new
      if @config['wildcard']
        io <<  "; Wildcard\n"
        io << generate_machine("*",@config['wildcard'])
        io << "\n"
      end
      io.string
    end
  end
  class Machine
    attr_reader :name,:ipv4,:ipv6
    def initialize(name,config) 
      @name = name
      @ipv4 = config['ipv4']
      @ipv6 = config['ipv6']
    end
    def ipv4?
      not @ipv4.nil?
    end
    def ipv6?
      not @ipv6.nil?
    end
    def to_s
      @name
    end
  end
end

zonecfg = RedZone::ZoneConfig.new 'zones.yml'
zonecfg.setup!
zonecfg.domains.each do |d|
  puts zonecfg.generate_domain(d)
end


