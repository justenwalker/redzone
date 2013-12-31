require 'redzone/lifetime'
module RedZone
  # DNS Record
  class Record
    # Returns a new instance of a domain record
    # @param [Hash] record
    # @option record [String] :name    The record name (Required)
    # @option record [String] :class   ('IN') The record class. (Optional)
    # @option record [String] :ttl     The ttl for the record (Optional)
    # @option record [String] :type    The type of record, eg: CNAME, A, AAAA. (Required)
    # @option record [String] :data    The record data (Required)
    # @option record [String] :comment A comment for the record
    def initialize(record)
      raise ArgumentError, ':name is required' unless record.has_key?(:name)
      raise ArgumentError, ':type is required' unless record.has_key?(:type)
      raise ArgumentError, ':data is required' unless record.has_key?(:data) 
      @name    = record[:name]
      @class   = record[:class] || 'IN'
      @type    = record[:type]
      if record.has_key?(:ttl) and not record[:ttl].nil?
        @ttl     = Lifetime.new(record[:ttl]).seconds
      end
      @data    = record[:data]
      if @type == "TXT"
        @data = '"%s"' % [@data.gsub(/^\s*"?|"?\s*$/,'').gsub(/\n/,'')]
      end
      if record.has_key?(:comment) and not record[:comment].nil?
        @comment = " ; %s" % [record[:comment]]
      end
    end
    # Returns the domain record as a string to be written in the zone file
    # @return [String] record line
    def to_s
      "%-20s %-8s %s    %-8s %-20s%s\n" % [@name, @ttl, @class, @type, @data, @comment || '']
    end
  end
end