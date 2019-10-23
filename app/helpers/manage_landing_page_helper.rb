module ManageLandingPageHelper


def convertHexToRGB(color_hex)

components =  color_hex.scan(/.{2}/)
@color_rgb = [];
# great, now try converting each component into DEC
components.each_with_index {|component,index| @color_rgb[index]= component.to_i(16)}
@color_rgb
end

# notice a slight problem in the output... we got ff00 for the HEX "red".
# We need some way to print ff0000 to get the proper CSS value
# try a simple loop for now...

def convertRGBToHex(color_rgb)
  @color_as_hex = ""


  color_rgb.each do |component|
    hex = component.to_s(16)
    if component < 10
      @color_as_hex << "0#{hex}"
    else
      @color_as_hex << hex.to_s
    end
  end

  "#"+@color_as_hex
end

def getCategoryTemplate
  form = {
    "category"=> "",
    "background_image"=> ""
  }
end

def getLocationTemplate

  location = {
    "title": "",
    "location": "",
    "background_image": ""
  }
end

def getSectionTypes
  sectionTypes =[
    {"kind"=> "info", "variation"=> "single_column" , "name"=> "Info Section" },
    {"kind"=> "info", "variation"=> "multi_column", "name"=> "Info Section with columns"},
    {"kind"=> "locations", "name"=> "Location Section"},
    {"kind"=> "listings", "name"=> "Listings Section"},
    {"kind"=> "categories", "name"=> "Categories Section"},
    {"kind"=> "video", "name"=> "Video Section"},
  ]
  
end


def getLandingPageSectionTemplate(kind,variation,id)
  if kind == "info" && variation == "single_column"
    return {"title"=> "","kind"=> kind, "variation"=> variation, "id"=> id}
  elsif kind == "info" && variation == "multi_column"
    return {"title"=> "","kind"=> kind, "variation"=> variation,"id"=> id, "columns"=> [{"title": ""},{"title": ""},{"title": ""}]}
  elsif kind == "locations"
    return {"id"=> id,"title"=> "","kind"=> kind,"locations"=> [{},{},{}]}
  elsif kind == "listings"
    return {"id"=> id,"title"=> "","kind"=> kind,"listings" => []}
  elsif kind == "categories"
    return {"id"=> id,"title"=> "","kind"=> kind,"categories" => [
      {"category": {}, "background_image": {}},
      {"category": {}, "background_image": {}},
      {"category": {}, "background_image": {}}
      ]}
  elsif kind == "video"
    return {"id"=> id,"kind"=> kind}
  end
end

# Now we've got all the tricks we need to shuffle between RGB and HEX.
end
