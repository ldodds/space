require 'rubygems'
require 'hpricot'
require 'hpricot/xchar'
require 'Util'

class ApolloDataTable
  # html:: file to load
  # name:: name for this dataset
  # heading_search:: alternate selector for finding table headers (some minor variations)
  def initialize(html, name, heading_search = "td span")
    @html = html
    @name = name
    parsed = Hpricot(@html)
    table = parsed.search("//table")

    headings = table.at("tr")

    @missions = {}
  
    heading_cells = headings.search( heading_search )

    heading_cells[1..heading_cells.length].each { |cell|
      if cell.to_plain_text() != " "
        mission = cell.to_plain_text()        
        @missions[mission] = Hash.new
        @missions[mission]["name"] = mission
      end      
    }
    
    data_rows = table.search("tr")
    read(data_rows)    
  end

  #
  # Read data from a block that consists of a sub-heading
  # which exists at index, and data that continues for a specified
  # number of rows afterwards
  def read_block(data_rows, index, rows, heading=nil)
    #get the sub-heading name
    if heading == nil
      heading = Util.clean_ws( data_rows[index].at("td span").to_plain_text() )
      #puts "Heading: #{heading}"      
    end
    
    #puts heading
    rows.times { |i|
      #puts i
      cell_row = index+i+1
      #puts cell_row
      cells = data_rows[ cell_row ].search("td")
      #get the field name
      field_name = Util.clean_ws( cells[0].to_plain_text() )
      if field_name != nil && field_name != "?"

        #puts field_name
        start = mission_start()
    
        for cell in cells[1..cells.length]
          #mission name 
          name = "Apollo #{start}"
          #puts name
          #puts field_name
          mission = @missions[name]      
          fields = mission[heading]
          if fields == nil
            fields = mission[heading] = Hash.new
          end
          
          fields[field_name] = Util.clean_ws( cell.to_plain_text() ) unless cell.to_plain_text() == "---" 
          mission[heading] = fields
          start = start + 1
        end    

      else
        $stderr.puts( "Skipping row #{cell_row}" )                       
      end
      
    }
          
  end
  
  #
  # Read from a single row into a specific field
  def read_from_row(field, data_rows, index)
    start = 7
    cells = data_rows[index].search("td")
    for cell in cells[1..cells.length] 
      name = "Apollo #{start}"
      mission = @missions[name]      
      mission[field] = Util.clean_ws( cell.to_plain_text() )
      start = start + 1
    end    
  end
  
  def to_rdf(root=true)
    triples = ""
    if root
        triples = Util.rdf_root()  
    end
    
    triples << "<!-- #{@name} -->\n\n"
    @missions.each_key { |mission|
      triples << write_mission_rdf( @missions[mission] )
    }
    
    if root
       triples << Util.rdf_end()
    end
    
    return triples    
  end          
  
end  
