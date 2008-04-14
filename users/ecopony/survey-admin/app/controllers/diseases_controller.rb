class DiseasesController < ApplicationController
  # GET /diseases
  # GET /diseases.xml
  def index
    @diseases = Disease.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @diseases }
    end
  end

  # GET /diseases/1
  # GET /diseases/1.xml
  def show
    @disease = Disease.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @disease }
    end
  end

  # GET /diseases/new
  # GET /diseases/new.xml
  def new
    @disease = Disease.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @disease }
    end
  end

  # GET /diseases/1/edit
  def edit
    @disease = Disease.find(params[:id])
  end

  # POST /diseases
  # POST /diseases.xml
  def create
    @disease = Disease.new(params[:disease])

    respond_to do |format|
      if @disease.save
        flash[:notice] = 'Disease was successfully created.'
        format.html { redirect_to(@disease) }
        format.xml  { render :xml => @disease, :status => :created, :location => @disease }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @disease.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /diseases/1
  # PUT /diseases/1.xml
  def update
    @disease = Disease.find(params[:id])

    respond_to do |format|
      if @disease.update_attributes(params[:disease])
        flash[:notice] = 'Disease was successfully updated.'
        format.html { redirect_to(@disease) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @disease.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /diseases/1
  # DELETE /diseases/1.xml
  def destroy
    @disease = Disease.find(params[:id])
    @disease.destroy

    respond_to do |format|
      format.html { redirect_to(diseases_url) }
      format.xml  { head :ok }
    end
  end
end
