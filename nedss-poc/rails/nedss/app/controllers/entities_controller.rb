class EntitiesController < ApplicationController
  
  append_view_path(RAILS_ROOT + '/app/views/' + controller_name)
  before_filter :set_valid_types
  before_filter :get_type, :only => :index
  before_filter :assure_type, :only => :new
  before_filter :set_type_new, :only => :create
  before_filter :set_type, :except => [:index, :new, :create]

  # GET /entities
  # GET /entities.xml
  def index
    @entities = Entity.find(:all, :conditions => @conditions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entities }
    end
  end

  # GET /entities/1
  # GET /entities/1.xml
  def show
    @entity = Entity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entity }
    end
  end

  # GET /entities/new
  # GET /entities/new.xml
  def new
    @entity = Entity.new(@default_values)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @entity }
    end
  end

  # GET /entities/1/edit
  def edit
    @entity = Entity.find(params[:id])
  end

  # POST /entities
  # POST /entities.xml
  def create
    @entity = Entity.new(params[:entity])

    respond_to do |format|
      if @entity.save
        flash[:notice] = "#{@type.capitalize} was successfully created."
        format.html { redirect_to(entity_url(@entity)) }
        format.xml  { render :xml => @entity, :status => :created, :location => @entity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /entities/1
  # PUT /entities/1.xml
  def update
    @entity = Entity.find(params[:id])

    respond_to do |format|
      if @entity.update_attributes(params[:entity])
        flash[:notice] = "#{@type.capitalize} was successfully updated."
        format.html { redirect_to(@entity) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /entities/1
  # DELETE /entities/1.xml1
  def destroy
    @entity = Entity.find(params[:id])
    @entity.destroy

    respond_to do |format|
      format.html { redirect_to(entities_url) }
      format.xml  { head :ok }
    end
  end

  private

  def set_valid_types
    @valid_types ||= %w(person animal material place)
  end
   
  # Index only
  def get_type
    @type = params[:type] || 'all'
    if @valid_types.include?(@type)
      @conditions = { :entity_type => @type }
    elsif @type == 'all'
      @conditions = {}
    else
      send_not_found
    end
  end

  # New only
  def assure_type
    @type = params[:type]
    if @valid_types.include?(@type)
      @default_values = { @type.to_sym => {}, :entities_location => {}, :address => {} }
    else
      send_not_found
    end
  end

  # Create only
  def set_type_new
    @type = params[:entity][:entity_type]  # hidden field
  end
  
  # Show, Edit, Update, and Destroy only
  def set_type
    @type = Entity.find(params[:id]).entity_type
  end

  def send_not_found
      render :text => "Resource not found. Please supply a 'type' parameter of [#{@valid_types.to_sentence(:connector => 'or')}]", 
             :status => 404
  end
end
