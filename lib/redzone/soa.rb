require 'redzone/lifetime'
module RedZone
  # A DNS Start of Authority (SOA) record
  #
  # Example
  # -------
  #
  #
  #        $ORIGIN  example.com.
  #        $TTL     3600 ; TTL = 1 Hour
  #        @        IN    SOA    ns1    hostmaster.example.com. (
  #                       20140104 ; sn  = serial number
  #                       3600 ; ref = refresh = 1 Hour
  #                       600 ; rt  = update retry = 10 Minutes
  #                       86400 ; ex  = expiry = 1 Day
  #        )
  #
  class SOA
    # Returns a new instance of a zone SOA record
    #
    # See [SOA reference](http://www.zytrax.com/books/dns/ch8/soa.html) 
    # for explaination of the fields.
    #
    # @param [Hash] opts
    # @option opts [String] :domain     Zone (domain) name
    # @option opts [String] :ns         Primary name server
    # @option opts [String] :hostmaster Email address of the zone file maintainer ('@' replaced by '.')
    # @option opts [String] :refresh    Time between refreshes from slave servers
    # @option opts [String] :retry      Time between retrying failed zone transfers
    # @option opts [String] :expire     The maximum time that a secondary server will keep trying to complete a zone transfer.
    # @option opts [String] :negative   The maximum negative caching time.
    # @option opts [String] :ttl        The minimum time-to-live that applies to all resource records in the zone file
    def initialize(opts)
      @domain     = opts[:domain]
      @ns         = opts[:ns]
      @hostmaster = escape(opts[:hostmaster]     || "hostmaster.#{@domain}") 
      @ttl        = Lifetime.new(opts[:ttl]      || '1H')
      @refresh    = Lifetime.new(opts[:refresh]  || '1H')
      @retry      = Lifetime.new(opts[:retry]    || '10M')
      @expire     = Lifetime.new(opts[:expire]   || '1D')
      @negative   = Lifetime.new(opts[:negative] || '1H')
    end
    # Returns the SOA record with the serial set to the current unix timestamp
    # @return [String] SOA Record
    def to_s
      to_soa(Time.now.to_i)
    end

    # Returns the SOA record with the given serial number
    # @param [Integer] serial Serial number (Usually YYYYMMDDnn)
    # @return [String] SOA Record
    def to_soa(serial)
      io = StringIO.new
      io << "$ORIGIN  #{@domain}.\n"
      io << "$TTL     #{@ttl.seconds} ; TTL = #{@ttl}\n"
      io << "@        IN    SOA    #{@ns}    #{@hostmaster} (\n"
      io << "               %-10s ; sn  = serial number\n" % [serial]
      io << "               %-10s ; ref = refresh = %s\n"  % [@refresh.seconds,@refresh] 
      io << "               %-10s ; rt  = retry   = %s\n"  % [@retry.seconds,@retry]
      io << "               %-10s ; ex  = expiry  = %s\n"  % [@expire.seconds,@expire]
      io << "               %-10s ; nx  = nxdomain ttl = %s\n"  % [@negative.seconds,@negative]
      io << ")\n\n"
      io.string
    end
    private 
    def escape(email)
      email.gsub(/@/,'.')
    end
  end
end