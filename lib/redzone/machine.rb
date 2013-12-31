require 'ipaddr'

module RedZone
  # Machine entry
  # @attr [String] name Relative domain name
  # @attr [IPAddr] ipv4 IPV4 Address
  # @attr [IPAddr] ipv6 IPV6 Address
  class Machine
    attr_reader :name,:ipv4,:ipv6
    # Construct a new machine entry
    # @param [String] name Relative domain name
    # @param [Hash] config Machine configuration
    # @option config [String] :ipv4 IPV4 Address
    # @option config [String] :ipv6 IPV6 Address
    def initialize(name,config) 
      @name  = name
      if config.is_a? Hash
        @alias = nil
        @ipv4  = IPAddr.new(config[:ipv4]) if config.has_key?(:ipv4)
        @ipv6  = IPAddr.new(config[:ipv6]) if config.has_key?(:ipv6)
      elsif config.is_a? Machine
        @alias = config
        @ipv4  = config.ipv4
        @ipv6  = config.ipv6
      end
    end
    # Returns true if this machine is an alias of another
    # @return [Boolean] true if the machine is an alias
    def alias? 
      not @alias.nil?
    end
    # Returns a new machine that is an alias of this machine.
    # If this machine is already an alias, it delegates this call
    # to the aliased machine rather than this one.
    # @return [Machine]
    def alias(name)
      if @alias.nil?
        Machine.new(name,self)
      else
        @alias.alias(name)
      end
    end
    # Test if the machine has an ipv4 address
    # @return [Boolean] if the machine has an ipv4 address
    def ipv4?
      not @ipv4.nil?
    end
    # Test if the machine has an ipv6 address
    # @return [Boolean] if the machine has an ipv6 address
    def ipv6?
      not @ipv6.nil?
    end
    # Get the list of A/AAAA records
    # @return [Array<Record>]
    def records
      r = []
      comment = "Machine #{@alias.name}" if not @alias.nil?
      if ipv4?
        ipv4opt = {:name => @name, :data => @ipv4.to_s, :type => 'A', :comment => comment }
        r << Record.new(ipv4opt)
      end
      if ipv6?

        ipv6opt = {:name => @name, :data => @ipv6.to_s, :type => 'AAAA', :comment => comment }
        r << Record.new(ipv6opt)
      end
      r
    end
  end
end