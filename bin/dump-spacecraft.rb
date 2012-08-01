$:.unshift File.join(File.dirname(__FILE__), "..", "lib")


require 'NSSDCSpacecraft'
require 'Util'
BASE="/home/ldodds/data/space/nssdc/cache"

#Mars Lander
#file = File.new( "/home/ldodds/data/space/nssdc/cache/1971-049F.html" )
#file = File.new( "/home/ldodds/data/space/nssdc/cache/1969-059A.html" )
#file = File.new( "/home/ldodds/data/space/nssdc/cache/SOT-1.html" )
#file = File.new( "/home/ldodds/data/space/nssdc/cache/2008-013A.html" )
#file = File.new( "/home/ldodds/data/space/nssdc/cache/2000-004H.html" )
#file = File.new( "/home/ldodds/data/space/nssdc/cache/2008-052A.html" )
file = File.new( "#{BASE}/#{ARGV[0]}.html" )
spacecraft = NSSDCSpacecraft.new( file )
#puts spacecraft.pretty_inspect()
puts spacecraft.to_rdf(true)

