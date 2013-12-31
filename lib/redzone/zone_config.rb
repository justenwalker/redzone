require 'yaml'
require 'redzone/zone'

module RedZone
  # Contains zone configurations
  class ZoneConfig
    # Return the list of Zone objects
    # @return [Array<Zone>] zone
    attr_reader :zones
    # Return the list of ArpaNetwork objects
    # @return [Array<ArpaNetwork>] arpa networks
    attr_reader :arpas
    def initialize(file)
      config = YAML.load_file(file)
      common = config['zones']['common']
      @zones = []
      @arpas = []
      config['zones'].each do |z,c|
        if z != 'common'
          cfg = common.merge(c)
          zone = Zone.new(z,cfg)
          @zones << zone
          @arpas.concat zone.generate_arpa_list()
        end
      end
    end
  end
end