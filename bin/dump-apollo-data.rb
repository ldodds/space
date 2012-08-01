$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'ApolloDesignations'
require 'ApolloCrew'
require 'ApolloCapComs'

designations = ApolloDesignations.new( File.new( "/home/ldodds/data/space/apollo/cache/Apollo_18-10_Designations.htm" ) )

#puts designations.pretty_inspect()
#puts designations.to_rdf(true)

#crew = ApolloLunarMissionsCrew.new( File.new( "/home/ldodds/data/space/apollo-in-numbers/Apollo_18-03_Crew_Information_-_Lunar_Landings.htm" ) )
#puts crew.pretty_inspect()
#puts crew.to_rdf()

#crew = ApolloOrbitMissionsCrew.new( File.new( "/home/ldodds/data/space/apollo/cache/Apollo_18-02_Crew_Information_-_E-Orbit_and_L-Orbit.htm" ) )
#puts crew.pretty_inspect()
#puts crew.to_rdf()

capcoms = ApolloCapComs.new( File.new( "/home/ldodds/data/space/apollo/cache/Apollo_18-06_Capsule_Communicators.htm" ), "Apollo CapComs" )
puts capcoms.to_rdf()

