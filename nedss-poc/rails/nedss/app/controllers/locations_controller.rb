class LocationsController < ApplicationController

  before_filter :find_entity

  # GET /locations
  # GET /locations.xml
  def index
    # We'll want to change this when we get more restful
    redirect_to entity_path(@entity)
  end

  # GET /location/1
  # GET /location/1.xml
  def show
    # We'll want to change this when we get more restful
    redirect_to entity_path(@entity)
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new(:entities_location => {:entity_id => @entity.id}, :address => {})

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = @entity.locations.find(params[:id])
    @location.entities_location = @entity.entities_locations.find_by_location_id(@location.id).attributes
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = Location.new(params[:location])
    respond_to do |format|
     if @location.save
        flash[:notice] = 'Location was successfully added.'
        format.html { redirect_to(entity_path(@entity)) }
        format.xml  { render :xml => @locations, :status => :created, :location => @locations }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @locations.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = @entity.locations.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location])
        flash[:notice] = 'Location was successfully updated.'
        format.html { redirect_to(entity_path(@entity)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @locations.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = @entity.locations.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(entity_path(@entity)) }
      format.xml  { head :ok }
    end
  end

  private 
  
  def find_entity
    redirect_to entity_url unless params[:entity_id]
    @entity = Entity.find(params[:entity_id])
    @type = @entity.entity_type
  end
end
