class CmrsController < ApplicationController
  # GET /cmrs
  # GET /cmrs.xml
  def index
    @cmrs = Cmr.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cmrs }
    end
  end

  # GET /cmrs/1
  # GET /cmrs/1.xml
  def show
    @cmr = Cmr.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cmr }
    end
  end

  # GET /cmrs/new
  # GET /cmrs/new.xml
  def new
    @cmr = Cmr.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cmr }
    end
  end

  # GET /cmrs/1/edit
  def edit
    @cmr = Cmr.find(params[:id])
  end

  # POST /cmrs
  # POST /cmrs.xml
  def create
    @cmr = Cmr.new(params[:cmr])

    respond_to do |format|
      if @cmr.save
        flash[:notice] = 'Cmr was successfully created.'
        format.html { redirect_to(@cmr) }
        format.xml  { render :xml => @cmr, :status => :created, :location => @cmr }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cmr.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cmrs/1
  # PUT /cmrs/1.xml
  def update
    @cmr = Cmr.find(params[:id])

    respond_to do |format|
      if @cmr.update_attributes(params[:cmr])
        flash[:notice] = 'Cmr was successfully updated.'
        format.html { redirect_to(@cmr) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cmr.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cmrs/1
  # DELETE /cmrs/1.xml
  def destroy
    @cmr = Cmr.find(params[:id])
    @cmr.destroy

    respond_to do |format|
      format.html { redirect_to(cmrs_url) }
      format.xml  { head :ok }
    end
  end
end
