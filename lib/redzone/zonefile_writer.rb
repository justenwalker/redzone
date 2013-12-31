require 'yaml'
require 'redzone/zone'

module RedZone
  # Writes zone configurations to files
  class ZonefileWriter
    # Constructs a ZonefileWriter
    def initialize(zone_config)
      @config = zone_config
    end
    # Write the zone database files to the target folder
    # @param [Pathname] target Target directory
    def write_zones(target)
      raise ArgumentError, "Directory #{target} does not exist" unless target.exist?
      @config.zones.each do |z|
        with_file(target,z.name) { |io| z.write(io) } 
      end
      @config.arpas.each do |a|
        with_file(target,a.name) {|io| a.write(io)}
      end
    end
    private
    def with_file(target,name,&block)
      filename = target + "#{name}.db"
      File.open(filename,"w") do |file|
        block.call(file)
      end
    end
  end
end