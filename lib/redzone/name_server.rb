module RedZone
  # NameServer record
  class NameServer
    # Name Server name / alias
    attr_reader :name

    # Get the target machine hosting the name server
    attr_reader :machine

    # Constructs a new NameServer
    # @param [String]  name Server name / alias
    # @param [Machine] machine Target machine
    def initialize(name,machine) 
      @name     = name
      @machine  = machine.alias(@name)
    end

    # Get the list of NS records
    # @return [Array<Record>]
    def records
      [Record.new(:name => "@", :type => "NS", :data => "#{@name}")]
    end
  end
end