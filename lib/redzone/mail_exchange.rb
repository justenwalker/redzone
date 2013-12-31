module RedZone
  # A mail server record
  class MailExchange
    # MX Server name / alias
    attr_reader :name

    # Get the target machine hosting the mail exchange
    attr_reader :machine
    
    # MX Priority
    attr_reader :priority
 
    # Constructs a new MailExchange entry
    # @param [String]  name Server name / alias
    # @param [Machine] machine Target machine
    # @param [Integer] priority MX priority setting
    def initialize(name,machine,priority) 
      @name     = name
      @machine  = machine.alias(@name)
      @priority = priority
    end
    # Get the list of MX records
    # @return [Array<Record>]
    def records
      [Record.new(:name => "@", :type => "MX", :data => "#{@priority} #{@name}")]
    end
  end
end