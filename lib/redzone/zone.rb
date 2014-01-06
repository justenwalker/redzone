require 'redzone/record'
require 'redzone/soa'
require 'redzone/machine'
require 'redzone/mail_exchange'
require 'redzone/name_server'
require 'redzone/arpa'

module RedZone
  # Represents a zone configuraton for a domain.
  #
  # Takes a zone configuration in the form of a hash.
  # this is usually read from a yaml file. The schema
  # for the yaml file can be found in the resources
  #
  class Zone
    # Returns the domain name of the zone
    # @return [String]
    attr_reader :name

    # Return the a list of machines
    # @return [Array<Machine>]
    attr_reader :machines

    # Return the SOA record
    # @return [SOA]
    attr_reader :soa

    # Returns the default machine for the domain when no subdomain is supplied
    # @return [Machine]
    attr_reader :default

    # Returns a list of name servers that service the zone
    # @return [Array<Machine>]
    attr_reader :nameservers

    # Returns a list of mail servers
    # @return [Array<Machine>]
    attr_reader :mailservers

    # Returns a list of alternate names for machines. 
    # These are additional A/AAAA records to the same
    # IP Address
    # @return [Array<Machine>]
    attr_reader :altnames

    # Returns a list of domain-name aliases
    # @return [Array<Record>]
    attr_reader :cnames

    # Returns the wildcard entry - the catch-all machine for dns queries
    # not matching any other subdomain entry.
    # @return [Machine]
    attr_reader :wildcard

    # Returns a list of additional zone records
    # @return [Array<Record>]
    attr_reader :records

    # Create a new Zone config
    # @param [String] name Domain name (eg: example.com)
    # @param [Hash] config Zone configuration
    def initialize(name,config)
      @name       = name
      @config     = config
      generate_machines()
      generate_aliases()
      generate_nameservers()
      generate_mailservers()
      generate_cnames()
      generate_records()
      @soa = generate_soa(@name)
      d  = get_machine('default')
      wc = get_machine('wildcard')
      if d
        @default = d.alias("@")
      end
      if wc
        @wildcard = wc.alias("*")
      end
    end

    # Writes a given set of Records to the target IO
    # @param [IO] io output IO Stream
    # @param [Array<Record>] records
    def write_records(io,records)
      unless records.nil? or records.empty?
        records.each do |r|
          io << r
        end
      end
    end

    # Writes the list of machines to the target IO
    # @param [IO] io output IO Stream
    # @param [Array<#records>] machines machines
    # @param [String] comment (nil) Optional comment to be prefixed to the record section
    def write_machines(io,machines,comment=nil)
      unless machines.nil? or machines.empty?
        io << "; #{comment}\n" unless comment.nil?
        machines.each do |m|
          write_records(io,m.records)
        end
        io << "\n"
      end
    end
    
    # Writes the entre zonefile to the target IO
    # @param [IO] io Target IO stream
    def write(io)
      io << soa
      unless default.nil?
        write_machines(io,[default],"Default Machine")
      end
      write_machines(io,nameservers,"Name Servers")
      write_machines(io,mailservers,"Mail Servers")
      write_machines(io,machines,"Primary Machine names")
      write_machines(io,altnames,"Alternate Machine Names")
      unless wildcard.nil?
        write_machines(io,[wildcard],"Wildcard Machine")
      end
      unless cnames.empty?
        io << "; Canonical Names\n"
        write_records(io,cnames)
        io << "\n"
      end
      
      unless records.nil? or records.empty?
        io << "; Extra Records\n"
        write_records(io,records)
        io << "\n"
      end
    end

    # Generates a list of Arpas for this zone
    # @return [Array<Arpa>]
    def generate_arpa_list
      arpas = []
      if @config.has_key?('arpa')
        @config['arpa'].each do |cfg|
          opts = symbolize(cfg)
          soa  = generate_soa(opts[:name])
          opts[:soa] = soa
          an = Arpa.new(opts)
          arpas << an
          @nameservers.each do |ns|
            an.add_record(Record.new(:name => '@', :type => 'NS', :data => ns.name + ".#{@name}." ))
          end
          @machines.each do |machine|
            an.add(machine,@name)
          end
        end
      end
      arpas
    end

    private
    def sorted_each(hash,&block)
      unless hash.nil?
        keys = hash.keys.sort
        keys.each do |key|
          block.call(key,hash[key])
        end
      end
    end
    def symbolize(hash) 
      hash.inject({}) do |memo,(k,v)|
        memo[k.to_sym] = v
        memo
      end
    end
    def generate_soa(name)
      opts = symbolize(@config['lifetimes'])
      opts[:hostmaster] = @config['hostmaster'] if @config.has_key?('hostmaster')
      opts[:domain]     = name
      opts[:ns]         = @nameservers[0].name + ".#{@name}." unless @nameservers.empty?
      SOA.new(opts)
    end
    def generate_machines
      @machines = []
      @allnames = []
      @machines_by_name = {}
      sorted_each(@config['machines']) do |n,c|
      #@config['machines'].each do |n,c|
        m = Machine.new(n,symbolize(c))
        @allnames << n
        @machines << m
        @machines_by_name[n] = m 
      end
    end
    def get_machine(name)
      if @machines_by_name.has_key?(name)
        @machines_by_name[name]
      else
        nil
      end
    end
    def generate_aliases
      machines = []
      if @config.has_key?('aliases')
        sorted_each(@config['aliases']) do |name,ref|
        #@config['aliases'].each do |name,ref|
          m = get_machine(ref)
          if not m.nil?
            machines  << m.alias(name)
            @allnames << name
          else
            puts "ERROR: No such machine named #{ref}"
          end
        end
      end
      @altnames = machines
    end
    def add_alias(name,machine)
      unless @allnames.include?(name)
        @altnames << machine.alias(name)
        @allnames << name
      end
    end
    def generate_mailservers
      machines = []
      if @config.has_key?('mailservers')
        sorted_each(@config['mailservers']) do |name,mx|
        #@config['mailservers'].each do |name,mx|
          ref = mx['machine']
          m  = get_machine(ref)
          if not m.nil?
            priority = mx['priority'] || 10
            machines << MailExchange.new(name,m,priority)
            add_alias(name,m)
          else
            puts "ERROR: No such machine named #{ref}"
          end
        end
      end
      @mailservers = machines
    end
    def generate_nameservers
      machines = []
      if @config.has_key?('nameservers')
        sorted_each(@config['nameservers']) do |name,ref|
        #@config['nameservers'].each do |name,ref|
          m = get_machine(ref)
          if not m.nil?
            machines << NameServer.new(name,m)
            add_alias(name,m)
          else
            puts "ERROR: No such machine named #{ref}"
          end
        end
      end
      @nameservers = machines
    end
    def generate_cnames
      @cnames = []
      sorted_each(@config['cnames']) do |k,v|
      #@config['cnames'].each do |k,v|
        data = v
        # Assume absolute domain name 
        # if value is not a machine name
        unless @allnames.include?(v)
          data = "#{v}."
        end
        @cnames << Record.new({
          :name => k,
          :type => 'CNAME',
          :data => data
        })
      end
      @cnames
    end
    def generate_records
      @records = []
      if @config.has_key?('records')
        @config['records'].each do |record|
          @records << Record.new(symbolize(record))
        end
      end
      @records
    end
  end
end
