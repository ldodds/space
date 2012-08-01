require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'hpricot/xchar'
require 'Util'
require 'iconv'

#Map nbsp to spaces
Hpricot::XChar::PREDEFINED_U.merge!({"&nbsp;" => 32})

class Image
    def initialize(link, thumbnail, caption, designator)
      @link = link
      @thumbnail = thumbnail
      @caption = caption
      @designator = designator
    end  
    
    def to_rdf(root=true)
      triples = ""
      if (root)
        triples = Util.rdf_root()
      end
      
      triples << "<!-- Image of #{@caption} -->\n"
      triples << "<foaf:Image rdf:about=\"#{image_link()}\">\n"
      triples << "  <foaf:thumbnail rdf:resource=\"#{thumbnail()}\"/>\n"
      triples << "  <foaf:depicts rdf:resource=\"http://data.kasabi.com/dataset/nasa/spacecraft/#{@designator}\"/>\n"
      triples << "</foaf:Image>"
      triples << "\n"
      
      triples << "<rdf:Description rdf:about=\"http://data.kasabi.com/dataset/nasa/spacecraft/#{@designator}\">" 
      triples << "  <foaf:depiction rdf:resource=\"#{image_link()}\"/>\n"
      triples << "</rdf:Description>"
      
      if (root)
        triples << Util.rdf_end()
      end
      
      return triples
    end
    
    def thumbnail()
      if @thumbnail.start_with?("http")
        return @thumbnail
      end
      return "http://nssdc.gsfc.nasa.gov#{@thumbnail}"
    end
    
    def image_link()
      if @link.start_with?("http")
        return @link
      end
      return "http://nssdc.gsfc.nasa.gov#{@link}"      
    end
end

class LaunchSite
  def initialize(launchsite)
      
      if launchsite.match(", null")
        @label = launchsite[0..-7]
        @place = @label
      else
        @label = launchsite
        @place, @country = launchsite.split(", ")                
      end

      
      normalized_placename = Util.normalize( @place )
      @id = "http://data.kasabi.com/dataset/nasa/launchsite/#{normalized_placename}"
      
  end  

  def to_rdf(root=true)
    triples = ""
    if (root)
      triples = Util.rdf_root
    end
    
    triples << "<!-- Launchsite -->\n"
    triples << "<space:LaunchSite rdf:about=\"#{@id}\">\n"
    triples << " <rdfs:label>#{Util.escape_xml(@label)}</rdfs:label>\n"
    
    #FIXME determine better triples for place and country
    
    triples << " <space:place>#{@place}</space:place>\n"
    
    if @country != nil
      triples << " <space:country>#{@country}</space:country>\n"
    else 
      triples << "\n"        
    end

    triples << "</space:LaunchSite>\n"

    if (root)
      triples << Util.rdf_end
    end    
    
    return triples
  end
    
  def to_s
    @label
  end
  
  attr_accessor :label, :place, :country, :id
end

class Launch
  def initialize(launchdate, launchsite, designator, launchvehicle)
      @launchdate = launchdate
      
      #E.g. 2008-004A.html
      if launchsite != "null"
        @launchsite = LaunchSite.new( launchsite )        
      end

      if launchvehicle != "null"
        @launchvehicle = launchvehicle  
      end
      
      @designator = designator
      @id = Util.generate_launch_id( @designator )  
  end
  
  def to_rdf(root=true)
    triples = ""
    if (root)
      triples = Util.rdf_root
    end
    
    triples << "<!-- Launch data for #{@designator} -->\n"
    triples << "<space:Launch rdf:about=\"#{@id}\">\n"
    triples << " <space:launched rdf:datatype=\"http://www.w3.org/2001/XMLSchema#date\">#{@launchdate}</space:launched>\n"
    if @launchvehicle != nil
      triples << " <space:launchvehicle>#{Util.escape_xml(@launchvehicle)}</space:launchvehicle>\n"
    end
    if @launchsite != nil
      triples << " <space:launchsite rdf:resource=\"#{@launchsite.id}\"/>\n"  
    end
    
    triples << "  <space:spacecraft rdf:resource=\"http://data.kasabi.com/dataset/nasa/spacecraft/#{@designator}\"/>\n"
    triples << "</space:Launch>"
    triples << "<rdf:Description rdf:about=\"http://data.kasabi.com/dataset/nasa/spacecraft/#{@designator}\"><space:launch rdf:resource=\"#{@id}\"/></rdf:Description>\n"
    if @launchsite != nil
      triples << @launchsite.to_rdf(false)  
    end    
    
    if (root)
      triples << Util.rdf_end
    end
    
    return triples
  end
  
  def to_s
    @id
  end
  
  attr_accessor :id, :launchdate, :launchsite, :designator, :launchvehicle, :missionProfile
  attr_writer :missionProfile    
end

class Discipline
    def initialize(discipline)
      @label = discipline
      @id = "http://data.kasabi.com/dataset/nasa/discipline/#{Util.normalize( discipline )}"
    end  
    
    def to_rdf(root=true)
      triples = ""
      if (root)
        triples = Util.rdf_root
      end
      
      #FIXME better as foaf:topic or some SKOS term?
      triples << "<!-- Discipline #{@label} -->\n"
      triples << "<space:Discipline rdf:about=\"#{@id}\">\n"
      triples << " <rdfs:label>#{Util.escape_xml(@label)}</rdfs:label>\n"
      triples << "</space:Discipline>\n"
      
      if (root)
       triples << Util.rdf_end
      end
      return triples
    end
    
    def to_s
      @label
    end
    
    attr_accessor :id, :label
end

class Agency
  #TODO
end

class NSSDCSpacecraft
  
  def NSSDCSpacecraft.list
    spacecraft = []

    #FIXME parse real url    
    #file = File.new( "C:\\downloads\\wget_files\\spacecraftSearch.do.htm" )
    url = "http://nssdc.gsfc.nasa.gov/nmc/spacecraftSearch.do?discipline=All"
    parsed_index = Hpricot( open(url) )
    
    table = parsed_index.search(".datatab")
    links = table.search("tr td a")
    links.each { |link|
      craft = {}
      craft["link"] = "http://nssdc.gsfc.nasa.gov#{link["href"]}"
      craft["name"] = link.inner_text   
      spacecraft << craft
    }
    
    return spacecraft
        
  end
  
  def initialize(html)
    @html = html
    parsed = Hpricot(@html)
        
    @name = parsed.at("#rightcontent h1").inner_text.sub("  ", " ")
    
    #Changed because of ids like ABLE1, etc
    #@id = parsed.at("#rightcontent p").inner_text.match("[0-9A-Z]{4}-[0-9A-Z]{4}")[0]
    @id = parsed.at("#rightcontent p").inner_text.match("NSSDC ID: (.+)")[1]
    
    descriptions = parsed.at(".urone")   
            
    #short description
    @description = descriptions.at("p").inner_text
    @description = clean_ws(@description)
    
    #store list of descs plus some special cases of interest     
    headings = descriptions.search("h4")
    @descriptionList = []
    missionProfile = nil
    #process headings in description section
    headings.each { |heading|
        desc = {}
        desc["title"] = heading.inner_html
        desc["text"] = clean_ws( heading.following_siblings()[0].to_plain_text )

        @descriptionList << desc
        
        if heading.inner_html == "Mission Profile"
          @missionProfile = desc["text"]
        end
        if heading.inner_html == "Spacecraft and Subsystems"
          @subsystems = desc["text"]
        end        
    }
                
    data_section = parsed.at(".urtwo")
    #processing other headings
    headings = data_section.search("h2")
    headings.each{ |heading|
      #alternate names
      if heading.to_plain_text == "Alternate Names"
        parse_names(heading)
      end
      #facts in brief
      if heading.to_plain_text == "Facts in Brief"
        parse_facts(heading)
      end
      if heading.to_plain_text == "Funding Agency"
        parse_agencies(heading)
      end
      if (heading.to_plain_text == "Discipline" ||
        heading.to_plain_text == "Disciplines")
        parse_disciplines(heading)
      end
      
      #TODO additional information links, including experiments and data
      
    }
    
    #find div containing image links
    capleft = parsed.at(".capleft")
    
    if capleft != nil
      parse_image(capleft)
    end
                       
  end

  #Parse out the image data
  def parse_image(elem)
    anchor = elem.at("a")
    #TODO
    if anchor == nil
      return
    end
    link = anchor["href"]
    image = anchor.at("img")
    thumbnail = image["src"]
    caption = clean_ws( elem.at("p").to_plain_text )
    @image = Image.new(link, thumbnail, caption, @id)
    
  end
  
  #Parse the alternate names for the spacecraft
  def parse_names(elem)
    nameList = elem.following_siblings()[0] #data_section.at("ul")
    names = nameList.search("li")
    @names = []
    names.each { |name|
      name = name.inner_html
      name.gsub! /\s{2,}/, " "
      @names << name 
    }    
  end
  
  #Parse out facts such as weight, power, etc
  def parse_facts(elem)
    para = elem.following_siblings()[0]
    values = para.search("strong")
    launchdate = nil
    launchvehicle = nil
    launchsite = nil
    values.each { |value| 
      field_name = value.inner_html
      field_value = value.next.to_plain_text.gsub /^\s/, ""
      # substrings are a hack for presence of &nbsp; at the start of some values
      if field_name == "Launch Date:"
        launchdate = field_value      
        elsif field_name == "Launch Vehicle:"
          launchvehicle = field_value
        elsif field_name == "Launch Site:"  
          launchsite = field_value
        elsif field_name == "Mass:"
          @mass = field_value.gsub /\skg/, ""
        elsif field_name == "Nominal Power:"
          #"Nominal Power: 375.0 W", 1966-073A.html          
          @nominalPower = clean_ws( field_value.gsub(/\sW/, "") ).gsub /\s/, ""
      else
        puts "Unknown field: #{field_name}"
      end
            
    }
    @launch = Launch.new(launchdate, launchsite, @id, launchvehicle)
  end
  
  #Parse out details of the funding agencies
  def parse_agencies(elem)
    #funding agency, detect country if Unknown
    agencies = elem.following_siblings()[0].search("li")
    @agencies = []
    agencies.each { |agency|        
        @agencies << agency.inner_html 
    }        
  end
  
  #Parse out the classification of the mission disciplines
  def parse_disciplines(elem)
    #disciplines, derive an id
    disciplines = elem.following_siblings()[0].search("li")
    @disciplines = []
    disciplines.each { |discipline|
      @disciplines << Discipline.new( discipline.inner_html ) 
    }    
  end
  
  #Util code for cleaning up whitespace, newlines, etc
  def clean_ws(s)
    Util.clean_ws(s)
  end
      
  def to_s
    return @name
  end  
  
  #Convert to rdf
  def to_rdf(root=true)
    triples = ""
    if root
       triples = Util.rdf_root  
    end
    triples << "<!-- Spacecraft #{@name} -->\n"
    triples << "<space:Spacecraft rdf:about=\"http://data.kasabi.com/dataset/nasa/spacecraft/#{@id}\">\n"
    triples << " <foaf:name>#{Util.escape_xml(@name)}</foaf:name>\n"
    triples << " <foaf:homepage rdf:resource=\"http://nssdc.gsfc.nasa.gov/database/MasterCatalog?sc=#{@id}\"/>\n"
    triples << " <space:internationalDesignator>#{@id}</space:internationalDesignator>\n"
    triples << " <dc:description>#{Util.escape_xml( @description )}</dc:description>\n"
    if @missionProfile != nil
      triples << "<space:missionProfile>#{Util.escape_xml( @missionProfile )}</space:missionProfile>\n"
    end
    
    #Agencies
    #FIXME temporary hack for demo
    if (@agencies != nil)
        agency = @agencies[0]
        country = /^(.+) \((.+)\)/.match(agency)
        triples << " <space:agency>#{country[2]}</space:agency>\n"
    end
    
    #TODO other descriptions
    
    if @names != nil
      @names.each { |name|
          triples << "<space:alternateName>#{Util.escape_xml( name )}</space:alternateName>\n"
      }
          end
        
    @disciplines.each { |d|
        triples << " <space:discipline rdf:resource=\"#{d.id}\"/>\n"
    }
    
    #FIXME is there a better property?
    if @nominalPower != nil
        triples << " <space:nominalPower>#{@nominalPower}</space:nominalPower>"
        if @mass != nil
          triples  << "\n"
        end
    end

    if @mass != nil
      triples << " <space:mass>#{@mass}</space:mass>\n"
      triples << "  \n"
    else 
      triples << "  \n"            
    end
    
    triples << "</space:Spacecraft>"
           
    #add launch data
    triples << @launch.to_rdf(false)
    
    #add disciplines       
    @disciplines.each { |d|
        triples << d.to_rdf(false)
    } 
    
    if @image != nil
      triples << @image.to_rdf(false)
    end
    
    if (root)
      triples << Util.rdf_end()
    end
    
    #quick fix convert to utf-8
    return Iconv.conv("utf-8", "iso-8859-1", triples)
    
  end
      
  attr_accessor :name, :id, :launchdate, :launchvehicle, :launchsite, :mass, :description, :descriptionList, :missionProfile, :subsystems, :names, :agencies, :disciplines
end
