require "chronic"

class LabEventsController < ApplicationController
  # GET /labevent
  # GET /labevent.xml
  def index
    @lab_events = LabEvent.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @person_entities }
    end
  end

  # GET /labevent/1
  # GET /labevent/1.xml
  def show
    @lab_event = LabEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /labevent/new
  # GET /labevent/new.xml
  def new
    @lab_event = LabEvent.new(:event_onset_date => Chronic.parse('today'), :disease => {}, :lab_result => {})

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /labevent/1/edit
  def edit
    @lab_event = LabEvent.find(params[:id])
  end

  # POST /labevent
  # POST /labevent.xml
  def create
    @lab_event = LabEvent.new(params[:lab_event])

    respond_to do |format|
      if @lab_event.save
        flash[:notice] = 'Lab event was successfully created.'
        format.html { redirect_to(lab_event_url(@lab_event)) }
        format.xml  { render :xml => @lab_event, :status => :created, :location => @lab_event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lab_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /labevent/1
  # PUT /labevent/1.xml
  def update
    @lab_event = LabEvent.find(params[:id])

    respond_to do |format|
      if @lab_event.update_attributes(params[:lab_event])
        flash[:notice] = 'Lab event was successfully updated.'
        format.html { redirect_to(lab_event_url(@lab_event)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lab_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /labevent/1
  # DELETE /labevent/1.xml
  def destroy
    #TODO: Make this a soft delete.  Currently orphans all children
    @lab_event = LabEvent.find(params[:id])
    @lab_event.destroy

    respond_to do |format|
      format.html { redirect_to(lab_events_url) }
      format.xml  { head :ok }
    end
  end
end
