class CategoriesController < ApplicationController
  resource_controller
  include Aegis::Controller
  permissions :categories, :except => [:index, :change_icon]

  def index
      session[:category_index_language] = @language = params[:language] || session[:category_index_language] || "french"
      session[:category_index_page] = params[:page] || session[:category_index_page]
      session[:category_index_per_page] = params[:per_page] || session[:category_index_per_page] || 10
      @per_page = session[:category_index_per_page]
      sql = "SELECT * FROM category_workflow_report ORDER BY #{@language}"
      @categories = Category.find_by_sql(sql).paginate(:page => session[:category_index_page], :per_page => @per_page)
  end

  def save_icon
    object.icon = params[:filename]
    object.save
    redirect_to edit_object_path(object)
  end

  def change_icon
    @icons =  Category.available_icons
  end

  def export
    report_name = "category_workflow_partner_report"
    send_data Report.new(report_name).to_csv, :filename => "#{report_name}.csv"
  end

  def show
    render :json => object.locations.to_geojson(:only => ["name"])
  end

  create.wants.html do
    redirect_to categories_path
  end

  update.wants.html do
    redirect_to categories_path
  end

end
