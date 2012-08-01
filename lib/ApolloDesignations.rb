require 'ApolloDataTable'

class ApolloDesignations < ApolloDataTable
  def initialize(html)
    super(html, "Apollo Designations")
  end
  
  def read(data_rows)
    #Call Signs 
    read_block(data_rows, 1, 2)
    #NASA/Contractor Designation
    read_block(data_rows, 5, 11)
    
    #International Designations        
    read_block(data_rows, 26, 5)
    #NORAD Designations        
    read_block(data_rows, 33, 5)
    
    read_from_row( "Eastern Test Range Number", data_rows, 24 )      
    
    #TODO computer programs
  end
  
  def mission_start()
    return 7
  end
  
  def write_mission_rdf( mission )    
    name = mission["name"]
    triples = "\n\n<!-- Mission Designation data for #{name} -->\n"
    mission_id = Util.absolute_uri("mission/" + name.downcase.gsub(/ /, "-"))
      
    international_designations = mission["International Designations"]
    lm_descent = international_designations["LM Descent Stage"]
    lm_ascent = international_designations["LM Ascent Stage[2] [#_ftn2]"]
    cms = international_designations["CSM"]
    lunar_subsat = international_designations["Lunar Subsatellite"]
    sivb = international_designations["S-IVB Stage"]
    
    triples << "<space:Mission rdf:about=\"#{mission_id}\">\n"
    triples << "  <dc:title>#{name}</dc:title>\n"    
    triples << "</space:Mission>\n\n"
       
    write_craft(mission_id, lm_descent, triples)
    write_craft(mission_id, lm_ascent, triples)
    write_craft(mission_id, sivb, triples)
    write_craft(mission_id, cms, triples)
    write_craft(mission_id, lunar_subsat, triples)

    return triples
  end
  
  def write_craft(mission_id, id, triples)
    if id == nil
      return
    end
    uri = Util.absolute_uri( "spacecraft/#{id}" )
    triples << "<space:Spacecraft rdf:about=\"#{uri}\">\n"
    triples << "  <space:mission rdf:resource=\"#{mission_id}\"/>\n"
    triples << "</space:Spacecraft>\n"     
  end
end