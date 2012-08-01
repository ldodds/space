require 'ApolloDataTable'

#
#  MissionRole
#      Commander, CommandModulePilot, LunarModulePilot
#
#     actor -> person
#     mission -> Mission 
#
#  Mission
#     role -> MissionRole
#

class ApolloCrew < ApolloDataTable
  
  def write_mission_rdf( mission )    
    mission_name = mission["name"]
    triples = "\n\n<!-- Mission Crew data for #{mission_name} -->\n"
    mission_id = Util.absolute_uri("mission/" + mission_name.downcase.gsub(/ /, "-"))
      
    write_commander(triples, mission_name, mission_id, mission)
    write_cm_pilot(triples, mission_name, mission_id, mission)
    write_lm_pilot(triples, mission_name, mission_id, mission)
  end
  
  def write_commander(triples, mission_name, mission_id, mission)
    role_uri = mission_id + "/role/commander"
    backup_role_uri = mission_id + "/role/backup-commander"
    label = "#{mission_name} Mission Commander"
    backup_label = "#{mission_name} Backup Mission Commander"
    actor_name = mission["Commander"]["Commander"]
    write_role(triples, mission_name, mission_id, role_uri, "http://data.kasabi.com/dataset/nasa/roles/mission-commander", label, mission["Commander"], actor_name)
    write_role(triples, mission_name, mission_id, backup_role_uri, "http://data.kasabi.com/dataset/nasa/roles/backup-mission-commander", backup_label, nil, mission["Commander"]["Backup"])
  end  

  def write_cm_pilot(triples, mission_name, mission_id, mission)
    role_uri = mission_id + "/role/command-module-pilot"
    backup_role_uri = mission_id + "/role/backup-command-module-pilot"
    label = "#{mission_name} Command Module Pilot"
    backup_label = "#{mission_name} Backup Command Module Pilot"
    actor_name = mission["Command Module Pilot"]["Command Module Pilot"]
    write_role(triples, mission_name, mission_id, role_uri, "http://data.kasabi.com/dataset/nasa/roles/command-module-pilot", label, mission["Command Module Pilot"], actor_name)
    write_role(triples, mission_name, mission_id, backup_role_uri, "http://data.kasabi.com/dataset/nasa/roles/backup-command-module-pilot", backup_label, nil, mission["Command Module Pilot"]["Backup"])
  end  

  def write_lm_pilot(triples, mission_name, mission_id, mission)
    role_uri = mission_id + "/role/lunar-module-pilot"
    backup_role_uri = mission_id + "/role/backup-lunar-module-pilot"      
    label = "#{mission_name} Lunar Module Pilot"
    backup_label = "#{mission_name} Backup Lunar Module Pilot"
    actor_name = mission["Lunar Module Pilot"]["Lunar Module Pilot"]
    write_role(triples, mission_name, mission_id, role_uri, "http://data.kasabi.com/dataset/nasa/roles/lunar-module-pilot", label, mission["Lunar Module Pilot"], actor_name)
    write_role(triples, mission_name, mission_id, backup_role_uri, "http://data.kasabi.com/dataset/nasa/roles/backup-lunar-module-pilot", backup_label, nil, mission["Lunar Module Pilot"]["Backup"])
  end  
  
      
  def write_role(triples, mission_name, mission_id, role_uri, role_type, label, actor, actor_name)
        
    triples << "<space:MissionRole rdf:about=\"#{role_uri}\">\n"
    triples << " <space:role rdf:resource=\"#{role_type}\"/>\n"
    triples << " <rdfs:label>#{label}</rdfs:label>\n"  
    triples << " <space:mission rdf:resource=\"#{mission_id}\"/>\n"
    
    actor_uri = Util.absolute_uri("person/" + Util.slug( actor_name ) )
    triples << " <space:actor rdf:resource=\"#{actor_uri}\"/>\n"
    triples << "</space:MissionRole>\n\n"
    write_person(triples, actor_uri, actor, actor_name, role_uri)
    return triples
        
  end
  
  def write_person(triples, actor_uri, person, person_name, role_id)
    triples << "<foaf:Person rdf:about=\"#{actor_uri}\">\n"
    triples << "  <space:performed rdf:resource=\"#{role_id}\"/>\n"
    triples << "  <foaf:name>" + person_name + "</foaf:name>\n"
    triples << "</foaf:Person>\n"
  end
  
end

class ApolloLunarMissionsCrew < ApolloCrew
  def initialize(html)
    super(html, "Apollo Lunar Missions Crew")
  end

  def read(data_rows)
    #Commanders
    read_block(data_rows, 1, 12, "Commander")
    #CM Pilot
    read_block(data_rows, 15, 13, "Command Module Pilot")
    #LM Pilot
    read_block(data_rows, 31, 12, "Lunar Module Pilot")
  end
 
  def mission_start()
    return 11
  end
    
end

class ApolloOrbitMissionsCrew < ApolloCrew
  def initialize(html)
    super(html, "Apollo Lunar Missions Crew", "td b")
  end

  def read(data_rows)
    #Commanders
    read_block(data_rows, 1, 12, "Commander")
    #CM Pilot
    read_block(data_rows, 15, 13, "Command Module Pilot")
    #LM Pilot
    read_block(data_rows, 31, 12, "Lunar Module Pilot")
  end

  def mission_start()
    return 7
  end
    
end
