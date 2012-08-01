$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'Util'
require 'NSSDCSpacecraft'
require 'open-uri'

puts "Parsing list of spacecraft..."
spacecraft = NSSDCSpacecraft.list
puts "Found #{spacecraft.length} spacecraft"

cache_dir = ARGV[0]
if !File.exists?(cache_dir)
  d = Dir.mkdir(cache_dir)  
end


spacecraft.each { |craft|   
    uri = URI.parse( craft["link"] )    
    puts "Processing #{uri}"
    cache_file_name = craft["link"].split("=")[1] + ".html"
    if ( File.exists?( File.join( cache_dir, cache_file_name ) ) )
      #puts "Skipping already cached file"
    else
      begin
        sleep(1)
        puts uri
        page_data = uri.read         
        puts "Writing #{cache_file_name}"   
        cache_file = File.new( File.join( cache_dir, cache_file_name ), "w" )
        cache_file.puts( page_data )      
        cache_file.close()
      rescue Errno::ETIMEDOUT
        puts "Timeout!"
      end                            
    end
}

