module Util
    
  def Util.rdf_root
    return "\
<rdf:RDF     
 xmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n\
 xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n\
 xmlns:foaf=\"http://xmlns.com/foaf/0.1/\"\n\
 xmlns:owl=\"http://www.w3.org/2002/07/owl#\"\n\
 xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n\
 xmlns:vs=\"http://www.w3.org/2003/06/sw-vocab-status/ns#\"\n\
 xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"\n\
 xmlns:space=\"http://purl.org/net/schemas/space/\">\n\n"    
  end
  
  def Util.rdf_end
    return "\n\n</rdf:RDF>"  
  end 
    

  def Util.slug(s)
    normalized = Util.normalize(s)
    normalized.gsub! /\./, ""
    normalized.gsub! /,/, ""
    return normalized    
  end 
    
  def Util.normalize(s)
    normalized = s.downcase
    normalized.gsub! /\s+/, ""
    normalized.gsub! /\(|\)/, ""
    
    normalized.gsub! /&/, ""
    normalized.gsub! /\?/, ""
    normalized.gsub! /\=/, ""
    
    return normalized    
  end 
  
  #Escape quotes for N3
  def Util.escape_quote(s)
    escaped = s
    escaped.gsub! /"/, '\\"'
    return escaped  
  end    
  
  def Util.escape_xml(s)
    escaped = s.dup
    
    escaped.gsub!("&", "&amp;")
    escaped.gsub!("<", "&lt;")
    escaped.gsub!(">", "&gt;")
            
    return escaped
    
  end
  def Util.generate_launch_id(designator)
    #International designators consist of the year, a incrementing count of launches
    #within that year and up to a three letter code distinguishing parts within a specific 
    #launch. Therefore a unique id for a launch can generally be derived from the identifier for a 
    #vehicle. E.g. Apollo command module is 1969-059A, so its launch id is 1969-059.
    launchid = designator
    if launchid.match( "([0-9]{4}-[0-9]{3})[A-Z]{1}" )
      launchid = launchid.match( "([0-9]{4}-[0-9]{3})[A-Z]{1}" )[1]
    end
    return "http://nasa.dataincubator.org/launch/#{launchid}"  
    
  end

  ILLEGAL_CHARS = /\x00|\x01|\x02|\x03|\x04|\x05|\x06|\x07|\x08|\x0B|
  \x0C|\x0E|\x0F|\x10|\x11|\x12|\x13|\x14|\x15|\x16|\x17|\x18|\x19|\x1A|
  \x1B|\x1C|\x1D|\x1E|\x1F/

      
  #Util code for cleaning up whitespace, newlines, etc
  def Util.clean_ws(s)
    cleaned = s.gsub /^\r\n/, ""
    cleaned.gsub! /\n/, ""    
    cleaned.gsub! /\s{2,}/, " "
    cleaned.gsub! /^\s/, ""
    
       
    cleaned.gsub! ILLEGAL_CHARS, " "
          
    return cleaned
  end
  
  def Util.absolute_uri(s)
    return "http://data.kasabi.com/dataset/nasa/#{s}"    
  end
end