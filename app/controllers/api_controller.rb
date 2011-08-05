require 'RMagick'

class ApiController < ApplicationController
  caches_page :icon
  skip_before_filter :require_user

  def categories
    sql = %{
      SELECT categories.id, french, icon, count(*) as count
      FROM categories
      JOIN tags ON tags.category_id = categories.id
      GROUP BY categories.id, french, icon
      ORDER BY french ASC
    }
    render :json => Category.connection.execute(sql).to_json, :callback => params[:callback]
  end

  def icon
    canvas = Magick::Image.new(24,24) { self.background_color = "#434343" }
    canvas.format = 'gif'
    canvas.border!(1,1,'#fff')
    image = Magick::Draw.new
    image.gravity = Magick::CenterGravity
    image.pointsize = 14
    image.stroke = 'transparent'
    image.fill = '#ffffff'
    image.font_weight = Magick::BoldWeight
    image.font_family = 'Helvetica'
    image.annotate(canvas, 0, 0, 0, 0, params[:num])
    send_data(canvas.to_blob, :type => "image/gif", :disposition => 'inline', :filename => "icon.gif")
  end

  def features
    query = Location
      .includes(:tags, :administrative_unit_0)
      .where("locations.searchable_name ilike '%#{params[:q]}%'")
      .where("status != 'INVALID'")
      .limit(99)

    if bounds = params[:bounds]
      box = bounds.split(',')
      query =  query.where("ST_Intersects(SetSRID('BOX(#{box[0]} #{box[1]},#{box[2]} #{box[3]})'::box2d::geometry, 4326), locations.feature)")
    end

    results = query.all.to_a

    unless results.size > 98
      query = Road
        .includes(:administrative_unit_0)
        .where("label ilike '%#{params[:q]}%'")
        .limit(99 - results.size)
        .select("id, label, the_geom, country_id, centroid")

      if bounds = params[:bounds]
        box = bounds.split(',')
        query = query.where("ST_Intersects(SetSRID('BOX(#{box[0]} #{box[1]},#{box[2]} #{box[3]})'::box2d::geometry, 4326), roads.centroid)")
      end

      results = results + query.all.to_a
    end

    render :json => results.to_geojson, :callback => params[:callback]
  end

  def route
    @geofactory = RGeo::Geographic.spherical_factory
    route = find_route(params["x1"], params["y1"], params["x2"], params["y2"])
    render :json =>  {route: RGeo::GeoJSON.encode(RGeo::GeoJSON::FeatureCollection.new(route))}.to_json, :callback => params[:callback]
  end

  def location
    id = params[:id]
    render :json => Location.find(id).to_geojson, :callback => params[:callback]
  end

  def locations
    bounds = params[:bounds].split(',')
    render :json => fetch_locations(bounds, params["category"], params["name"]), :callback => params[:callback]
  end

  private

  def find_route(x1, y1, x2, y2)
    sql = "SELECT * FROM geocms_find_route(#{x1}, #{y1}, #{x2}, #{y2})"
    Road.connection.execute(sql).map do |row|
      geometry = @geofactory.parse_wkt(row["a"])
      feature = RGeo::GeoJSON::Feature.new(geometry, nil, {"label" => row["b"], "start_angle" => row["d"], "end_angle" => row["e"]})
      feature
    end
  end

  def fetch_locations(bounds, category, name)
    query = Location
      .includes(:tags, :administrative_unit_0, :city)
      .limit(99)
      .where("ST_Intersects(SetSRID('BOX(#{bounds[0]} #{bounds[1]},#{bounds[2]} #{bounds[3]})'::box2d::geometry, 4326), locations.feature)")
      .where("status != 'INVALID'")
    if category
      query = query.where("tags.category_id = #{category}")
    elsif name
      query = query.where("locations.searchable_name ILIKE '%#{name}%'")
    else
      raise "No filtering criteria have been provided"
    end
    query.all.to_a.to_geojson
  end

end