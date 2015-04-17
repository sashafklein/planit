class Api::V1::Plans::KmlController < ApiController

  before_action :load_plan, except: []

  def index
    permission_denied_error unless current_user

    kml = KMLFile.new
    folder = KML::Folder.new( name: @plan.name )
    folder.features = @plan.items.with_places
      .map{ |i| KML::Placemark.new(
        name: i.name,
        style_url: "#exampleStyleMap",
        geometry: KML::Point.new( :coordinates => {:lat => i.lat, :lng => i.lon} ),
        description: "#{i.id}",
      )}
    kml.objects << folder
    send_data add_extras( kml.render ),
      :type => "text/xml; charset=UTF-8;",
      :disposition => "attachment; filename=Planit_#{@plan.name.split(" ").join("_")}.kml"
  end

  private

  def add_extras( kml )
    @plan.items.with_places.each{ |i| 
      kml = kml.gsub( """<description>\n        <![CDATA[#{i.id}]]>\n      </description>""", details(i) )
    }
    kml = kml.gsub("""<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<objects type=\"array\">\n  """,'')
    kml = kml.gsub("""</object>\n</objects>\n""","""</object>\n""")
    kml = kml.gsub("""<name>#{@plan.name}</name>""","""<name>#{@plan.name}</name>\n#{icon_settings}""")
    return kml
  end

  def details(item)
    return visible_description(item) # + extended_data(item)
  end

  # def extended_data(item)
  #   "<ExtendedData><data name='planit'><value>" + KmlItemSerializer.new(item).to_json.to_s + "</value></data></ExtendedData>"
  # end

  def visible_description(item)
    breakline = '&lt;br&gt;'
    lines = [
      # ( date_time(item).present? ? "#{breakline}When:#{date_time(item)}" : nil ),
      alt_names(item),
      item.categories.join(' / '),
      breakline + item.street_addresses.join(breakline),
      item.sublocality,
      item.locality,
      "<a href='https://maps.google.com?daddr=#{item.lat},#{item.lon}' target='_blank'>Get Directions</a>" + breakline,
      ( item.phone ? 'P: '+item.phone : nil ),
      "#{breakline}<a href='http://plan.it#{item.href}' target='_blank'>http://plan.it#{item.href}</a>",
      ( notes(item).present? ? notes(item) : nil ),
    ]
    "<description>" + remove_symbols( lines.compact.join(breakline) ) + "</description>"
  end

  def notes(item)
    breakline = '&lt;br&gt;'
    item_notes = item.notes.map{ |n| "#{breakline}&lt;b&gt;#{n.source.name}&lt;/b&gt; notes &quot;#{n.body}&quot;" }
    mark_notes = item.mark.notes.map{ |n| "#{breakline}&lt;b&gt;#{n.source.name}&lt;/b&gt; notes &quot;#{n.body}&quot;" }
    item_notes.compact.uniq.join(" ") + mark_notes.compact.uniq.join(" ")
  end

  # def date_time(item)
  #   return @date_time if @date_time    
  #   start_date = @plan.starts_at
  #   date = start_date ? start_date.strftime('%y%m%d') + item.day - 1 : nil
  #   day = item.day ? "Day " + item.day : nil
  #   time = item.start_time ? item.start_time
  #   duration = item.start_time ? item.duration : ( item.duration ? item.duration + 'hours')
  #   date_time = [ date, day, time, duration ].compact
  #   date_time ? @date_time = date_time.join(' : ') : nil
  # end

  def alt_names(item)
    item.names.delete(item.name)
    item.names.present? ? "AKA: " + item.names.join(' / ') : nil
  end

  def icon_settings
    '<Style id="highlightPlacemark"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/paddle/blu-stars-lv.png</href></Icon></IconStyle></Style><Style id="normalPlacemark"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/paddle/red-stars-lv.png</href></Icon></IconStyle></Style><StyleMap id="exampleStyleMap"><Pair><key>normal</key><styleUrl>#normalPlacemark</styleUrl></Pair><Pair><key>highlight</key><styleUrl>#highlightPlacemark</styleUrl></Pair></StyleMap>'
  end

  def remove_symbols(string)
    string = string.gsub(" & ", "&amp;")
  end
    
  def load_plan
    @plan = Plan.friendly.find params[:plan_id]
  end

end