require 'ipaddr'

module RedZone
  # Arpa definition
  class Arpa
    # Reverse DNS name 
    # @return [String] dns name
    attr_reader :name

    # Network
    # @return [IPAddr]
    attr_reader :network

    # Get the list of PTR records
    # @return [Array<Record>] PTR records
    attr_reader :records

    # Constructs a new MailExchange entry
    # @param [Hash<String, SOA>] opt
    # @option opt [String] :name Arpa DNS name (Required)
    # @option opt [String] :network IP address with network mask (Required)
    # @option opt [SOA,String] :soa SOA record  (Required)
    def initialize(opt) 
      raise ArgumentError, ':name is required' unless opt.has_key?(:name)
      raise ArgumentError, ':network is required' unless opt.has_key?(:network)
      raise ArgumentError, ':soa is required' unless opt.has_key?(:soa)
      @name     = opt[:name]
      @network  = IPAddr.new(opt[:network])
      @soa      = opt[:soa]
      @records  = []
    end

    # Writes the Arpa to the given IO stream
    # @param [IO] io IO Stream
    def write(io)
      io << @soa
      @records.each do |r|
        io << r
      end
      io << "\n"
    end

    # Adds a machine to the arpa network for reverse-address lookup
    # only if the machine is in this network.
    # @param [Machine] machine
    # @param [String] domain name
    def add(machine,domain)
      fqdn   = "#{machine.name}.#{domain}."
      substr = ".#{@name}"
      if @network.ipv4? and machine.ipv4? and @network.include?(machine.ipv4)
        ip = machine.ipv4.reverse
        ip.slice!(substr)
        records   << Record.new(:name => ip, :type => "PTR", :data => fqdn, :comment => "Machine #{machine.name}")
      end
      if @network.ipv6? and machine.ipv6? and @network.include?(machine.ipv6)
        ip = machine.ipv6.ip6_arpa
        ip.slice!(substr)
        records   << Record.new(:name => ip, :type => "PTR", :data => fqdn, :comment => "Machine #{machine.name}")
      end
    end

    def add_record(record)
      records << record
    end
  end
end