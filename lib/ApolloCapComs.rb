class ApolloCapComs
  
  # html:: file to load
  # name:: name for this dataset
  # heading_search:: alternate selector for finding table headers (some minor variations)
  def initialize(html, name)
    @html = html
    @name = name
    parsed = Hpricot(@html)
    @table = parsed.search("//table")
  end

  def to_rdf(root=true)
    triples = ""
    if root
        triples = Util.rdf_root()  
    end
    
    triples << "<!-- #{@name} -->\n"

    triples << write_mission(triples, "Apollo 7", 1, 6, 0)
    triples << write_mission(triples, "Apollo 8", 9, 7, 0)
    triples << write_mission(triples, "Apollo 9", 18, 6, 0)
    triples << write_mission(triples, "Apollo 10", 26, 4, 0)
    
    triples << write_mission(triples, "Apollo 11", 1, 10, 1)
    
    triples << write_mission(triples, "Apollo 12", 13, 7, 1)
    
    triples << write_mission(triples, "Apollo 13", 1, 5, 2)
    triples << write_mission(triples, "Apollo 14", 8, 4, 2)
    
    triples << write_mission(triples, "Apollo 15", 14, 9, 2)
    
    triples << write_mission(triples, "Apollo 16", 1, 9, 3)
    triples << write_mission(triples, "Apollo 17", 12, 9, 3)
    
        
    if root
       triples << Util.rdf_end()
    end
    
    return triples    
  end    
    
  def write_mission(triples, mission_name, startrow, count, column)
    mission_id = Util.absolute_uri("mission/" + mission_name.downcase.gsub(/ /, "-"))
    role_uri = mission_id + "/role/capsule-communicator"
      
    triples = "\n\n<!-- Capcoms for #{mission_name} -->\n"
    rows = @table.search("tr")[startrow,count]
    #FIXME should always be there?
    if rows != nil
      rows.each_with_index do |row, i|
        #puts row.search("td p span")[0].to_plain_text()
        actor_name = row.search("td")[column].to_plain_text()
        actor_name = clean_name(actor_name)
        write_role( triples, mission_name, mission_id, "#{role_uri}/#{i}", actor_name )
      end
    end
    return triples
  end
  
  def clean_name(actor_name)
  
    actor_name = actor_name.gsub(/((Lt|Maj|Col|Cdr|Capt)\. )+/, "")
    actor_name = actor_name.gsub(/, USAF\/Sc\. D\./, "")
    actor_name = actor_name.gsub(/, USN\/MD\/MC/, "")
    
    actor_name = actor_name.gsub(/, (USN|USMC|Ph\. D\.|USAF)$/, "")  
    return actor_name
  end
  
  def write_role(triples, mission_name, mission_id, role_uri, actor_name)
        
    triples << "<space:MissionRole rdf:about=\"#{role_uri}\">\n"
    triples << " <space:role rdf:resource=\"http://data.kasabi.com/dataset/nasa/roles/capsule-communicator\"/>\n"
    triples << " <rdfs:label>#{mission_name} Capsule Communicator</rdfs:label>\n"  
    triples << " <space:mission rdf:resource=\"#{mission_id}\"/>\n"
    
    actor_uri = Util.absolute_uri("person/" + Util.slug( actor_name ) )
    triples << " <space:actor rdf:resource=\"#{actor_uri}\"/>\n"
    triples << "</space:MissionRole>\n\n"
    triples << "<rdf:Description rdf:about=\"#{mission_id}\"><space:missionRole rdf:resource=\"#{role_uri}\"/></rdf:Description>\n"
    write_person(triples, actor_uri, actor_name, role_uri)       
  end
    
  def write_person(triples, actor_uri, person_name, role_id)
    triples << "<foaf:Person rdf:about=\"#{actor_uri}\">\n"
    triples << "  <space:performed rdf:resource=\"#{role_id}\"/>\n"
    triples << "  <foaf:name>" + person_name + "</foaf:name>\n"
    triples << "</foaf:Person>\n"
  end    
end