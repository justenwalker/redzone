require 'thor'

require 'redzone/zone_config'
require 'redzone/zonefile_writer'
require 'redzone/environment'
module RedZone
  # RedZone Command-line actions
  class Cli < Thor
    package_name 'RedZone'
    class_option :zones, :type => :string, :default => RedZone::Environment.default_zonefile ,:desc => <<-eos.strip
      RedZone zone configuration.
    eos
    #class_option :config, :type => :string, :desc => <<-eos.strip
    #  RedZone configuration file. (Default: #{RedZone::Environment.default_configfile})
    #eos
  
    desc 'generate [DIRECTORY]', <<-eos.strip
      Generates a bind database files into the given DIRECTORY.
      If DIRECTORY is not supplied, it defaults to '#{RedZone::Environment.default_var_named}'
    eos
    #  Generates a bind database files into the given directory.
    def generate(dir=nil)
      target = dir || RedZone::Environment.default_var_named.to_s
      c = ZoneConfig.new(options[:zones])
      writer = ZonefileWriter.new(c)
      writer.write_zones(Pathname.new(dir))
    end
    
    desc 'version', 'Shows the current version of redzone'
    # Prints the current RedZone version to the console
    def version
      say "redzone v#{RedZone::VERSION}"
    end
  end
end
