class FormStatusesController < ApplicationController
  # GET /form_statuses
  # GET /form_statuses.xml
  def index
    @form_statuses = FormStatus.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @form_statuses }
    end
  end

  # GET /form_statuses/1
  # GET /form_statuses/1.xml
  def show
    @form_status = FormStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @form_status }
    end
  end

  # GET /form_statuses/new
  # GET /form_statuses/new.xml
  def new
    @form_status = FormStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @form_status }
    end
  end

  # GET /form_statuses/1/edit
  def edit
    @form_status = FormStatus.find(params[:id])
  end

  # POST /form_statuses
  # POST /form_statuses.xml
  def create
    @form_status = FormStatus.new(params[:form_status])

    respond_to do |format|
      if @form_status.save
        flash[:notice] = 'FormStatus was successfully created.'
        format.html { redirect_to(@form_status) }
        format.xml  { render :xml => @form_status, :status => :created, :location => @form_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @form_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /form_statuses/1
  # PUT /form_statuses/1.xml
  def update
    @form_status = FormStatus.find(params[:id])

    respond_to do |format|
      if @form_status.update_attributes(params[:form_status])
        flash[:notice] = 'FormStatus was successfully updated.'
        format.html { redirect_to(@form_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @form_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /form_statuses/1
  # DELETE /form_statuses/1.xml
  def destroy
    @form_status = FormStatus.find(params[:id])
    @form_status.destroy

    respond_to do |format|
      format.html { redirect_to(form_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
