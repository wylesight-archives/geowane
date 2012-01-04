class LocationsController < ApplicationController
  include Aegis::Controller
  resource_controller
  layout "admin"
  before_filter :assign_form_data, :only => [:create, :edit]

  def per_page
    @per_page = params[:per_page] || 10
  end

  def page
    params[:page] || 1
  end

  def index
    search = Search.new(params[:s], params[:sort])
    search_results = search.execute(page, per_page)
    @total_entries = search_results[:total_entries]
    @locations = search_results[:locations]
    respond_to do |format|
      format.html do
        @categories = Category.dropdown_items
        @users = User.dropdown_items
        @boundaries = Boundary.dropdown_items(0)
        @statuses = Location.new.enums(:status).select_options.map {|x| [x[0].upcase, x[1]]}
      end
      format.json do
        render :json => {locations: @locations, total_entries: @total_entries}
      end
    end
  end

  def new
    @location = Location.new
    @location.name = "Change Me"
    @location.longitude = -4
    @location.latitude = 5
    @location.user = current_user
    @location.save!
    redirect_to edit_location_path(@location)
  end

  def next
    redirect_to edit_location_path(Search.new(params[:s]).next(params[:id]), :page => page, :per_page => per_page, :s => params[:s])
  end

  def previous
    redirect_to edit_location_path(Search.new(params[:s]).previous(params[:id]), :page => page, :per_page => per_page, :s => params[:s])
  end

  def collection_delete
    locations = LocationCollection.new(params[:locations])
    locations.destroy_all(current_user)
    redirect_to locations_path({:s => params[:s]})
  end

  def collection_edit
    if request.post?
      session[:collection] = params[:locations]
      redirect_to "/locations/edit"
    else
      @locations = Location.includes(:comments, :tags, :user).find(session[:collection], :order => "name")
      respond_to do |format|
        format.json do
          render :json => @locations.to_geojson
        end
        format.html do
          @categories = ["", ""] + Category.order("french").map{|c| [c.french, c.id]}
          @comments_cache = @locations.map do |loc|
            loc.comments.map {|x| {location_id: x.commentable_id, created_at: x.created_at, text: x.comment, user: x.user.login}}
          end.reject{|x| x.empty?}.flatten.to_json
          @locations_cache = @locations.map {|location| location.to_geojson}.to_json
        end
      end
    end
  end

  def collection_update
    if params[:commit]
      locations = []
      params[:locations].values.each do |attributes|
        location = Location.find(attributes.delete(:id))
        location.update_attributes(attributes)
        location.save!
        locations << location
      end
      if request.xhr?
        render :json => locations.to_geojson
      else
        redirect_to locations_path(:page => session[:search_page], :per_page => session[:search_page_size])
      end
    else
      collection = LocationCollection.new(params[:locations])
      render :json => collection.send(params[:call], params[:category]).to_json
    end
  end

  def edit
    @categories = Category.dropdown_items
    render :layout => false
  end

  show do
    wants.json do
      @items = Location.find(params[:id].split(","))
      render :json => @items.to_a.to_geojson
    end
  end

  update do
    wants.html do
      redirect_to locations_path(:page => session[:search_page], :per_page => session[:search_page_size])
    end
    wants.json do
      render :json => object.to_geojson
    end
  end

  def assign_form_data
    @form_data = {"categories" => Category.order("french")}
  end

end
