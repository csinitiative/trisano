class LocationsController < ApplicationController

  before_filter :find_person

  # GET /locations
  # GET /locations.xml
  def index
    @locations = @person_entity.current_locations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @location = @person_entity.current_location_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @entities_location = EntitiesLocation.new
    @location = Location.new
    @address = Address.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = @person_entity.locations.find(params[:id])
    @entities_location = @person_entity.entities_locations.find(@location.id)
    @address = @location.current_address
  end

  # POST /locations
  # POST /locations.xml
  def create
    @address = Address.new(params[:address])

    # associate the address with a location
    @location = Location.new
    @location.addresses << @address

    # Associate the location with the join model, add location type: Home, work, etc.
    entities_location = EntitiesLocation.new(params[:entities_location])
    entities_location.location = @location

    respond_to do |format|
      # Attach the join model -> location -> address to the person entity
      if (@address.valid?) && (@person_entity.entities_locations << entities_location)
        flash[:notice] = 'Location was successfully added.'
        format.html { redirect_to(person_path(@person_id)) }
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
    @location = @person_entity.locations.find(params[:id])
    @entities_location = @person_entity.entities_locations.find(@location.id)

    @entities_location.attributes=(params[:entities_location])
    @address = Address.new(params[:address])

    respond_to do |format|
      if @entities_location.transaction do
          @entities_location.save
          @location.addresses << @address
        end
        flash[:notice] = 'Locations was successfully updated.'
        format.html { redirect_to(person_path(@person_id)) }
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
    @entities_location = @person_entity.entities_locations.find(params[:id])
    @entities_location.destroy

    respond_to do |format|
      format.html { redirect_to(person_path(@person_id)) }
      format.xml  { head :ok }
    end
  end

  private 
  
  def find_person
    @person_id = params[:person_id]
    redirect_to people_url unless @person_id
    @person_entity = PersonEntity.find(@person_id)
    @person = @person_entity.current
  end
end
