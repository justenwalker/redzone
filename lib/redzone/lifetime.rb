module RedZone
  # Simple time parser for TTL/SOA lifetimes
  #
  # The simple time format format is a number followed by a time unit.
  #
  # ie: `<Number> [Unit]`
  #
  # Where the `Unit` is one of
  #
  # - `M`: Minute(s)
  # - `H`: Hour(s)
  # - `D`: Day(s)
  # - `W`: Week(s)
  #
  # If the units are missing, it is assumed to be in seconds
  # 
  class Lifetime
    # Constructs a lifetime object from a string
    # @param [String] str time stirng
    def initialize(str)
      if str.upcase =~ /([0-9]+)\s*([HDWM]?)/
        i    = $1.to_i
        pl   = "s" if i > 1
        pl ||= ""
        time = case $2
          when 'H' then [i * 3600,"#{i} Hour#{pl}"]
          when 'D' then [i * 86400,"#{i} Day#{pl}"]
          when 'M' then [i * 60,"#{i} Minute#{pl}"]
          when 'W' then [i * 604800,"#{i} Week#{pl}"]
          else [i,"#{i} Second#{pl}"]
        end
        @time = time.first
        @str  = time.last
      end
    end
    # Returns the lifetime as seconds
    # @return [Integer] seconds
    def seconds
      @time
    end
    # Returns the string representaton of the lifetime
    #
    # Examples:
    #
    # - 300 Seconds
    # - 1 Minute
    # - 2 Hours
    # - 1 Day
    # - 2 Weeks
    # @return [String]
    def to_s
      @str
    end
  end
end