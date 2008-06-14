class LabResultsController < ApplicationController

  before_filter :get_cmr

  # GET /lab_results
  # GET /lab_results.xml
  def index
    @lab_results = LabResult.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lab_results }
    end
  end

  # GET /lab_results/1
  # GET /lab_results/1.xml
  def show
    @lab_result = LabResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lab_result }
    end
  end

  # GET /lab_results/new
  # GET /lab_results/new.xml
  def new
    @lab_result = LabResult.new

    render :layout => false
  end

  # GET /lab_results/1/edit
  def edit
    @lab_result = LabResult.find(params[:id])
  end

  # POST /lab_results
  # POST /lab_results.xml
  def create
    @lab_result = LabResult.new(params[:lab_result])

    if (@event.lab_results << @lab_result)
      render(:update) do |page|
        page.replace_html "lab-result-list", :partial => 'lab_results/index'
        page.call "RedBox.close"
      end
    else
      # This will do for now.
      render(:update) do |page|
        page.call "alert", "Validation failed: #{@lab_result.errors.full_messages}"
      end
    end
  end

  # PUT /lab_results/1
  # PUT /lab_results/1.xml
  def update
    @lab_result = LabResult.find(params[:id])

    respond_to do |format|
      if @lab_result.update_attributes(params[:lab_result])
        flash[:notice] = 'LabResult was successfully updated.'
        format.html { redirect_to(@lab_result) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lab_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lab_results/1
  # DELETE /lab_results/1.xml
  def destroy
    @lab_result = LabResult.find(params[:id])
    @lab_result.destroy

    respond_to do |format|
      format.html { redirect_to(lab_results_url) }
      format.xml  { head :ok }
    end
  end

  private

  def get_cmr
    @event = Event.find(params[:cmr_id])
  end
end
