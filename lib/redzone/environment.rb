require 'pathname'

module RedZone
  # RedZone environment properties
  module Environment
    # Get the default etc path
    # @return [Pathname] default etc path
    def self.default_etc
      Pathname.new('/etc/redzone')
    end
    # Get the default location of the zone file
    # @return [Pathname] default zones.yml path
    def self.default_zonefile
      self.default_etc.join('zones.yml')
    end
    # Get the default location of the config file
    # @return [Pathname] default config.yml path
    def self.default_configfile
      self.default_etc.join('config.yml')
    end
 end
end
