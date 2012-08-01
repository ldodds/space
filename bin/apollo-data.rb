$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'ApolloDesignations'
require 'ApolloCrew'
require 'ApolloCapComs'

if !File.exists?(ARGV[1])
  Dir.mkdir( ARGV[1] )  
end

out = File.new( File.join(ARGV[1], "apollo.rdf"), "w")
out.write Util.rdf_root() 

designations = ApolloDesignations.new( File.new( "#{ARGV[0]}/Apollo_18-10_Designations.htm" ) )
out.puts( designations.to_rdf(false) )

crew = ApolloLunarMissionsCrew.new( File.new( "#{ARGV[0]}/Apollo_18-03_Crew_Information_-_Lunar_Landings.htm" ) )
out.puts( crew.to_rdf(false) )

crew = ApolloOrbitMissionsCrew.new( File.new( "#{ARGV[0]}/Apollo_18-02_Crew_Information_-_E-Orbit_and_L-Orbit.htm" ) )
out.puts( crew.to_rdf(false) )

capcoms = ApolloCapComs.new( File.new( "/home/ldodds/data/space/apollo/cache/Apollo_18-06_Capsule_Communicators.htm" ), "Apollo CapComs" )
out.puts( capcoms.to_rdf(false) )
out.write Util.rdf_end()