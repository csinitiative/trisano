require "chronic"

class EventsController < ApplicationController
  # GET /event
  # GET /event.xml
  def index
    @events = Event.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @person_entities }
      format.csv
    end
  end

  # GET /event/1
  # GET /event/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
      format.csv
    end
  end

  # GET /event/new
  # GET /event/new.xml
  def new
    @event = Event.new(:event_onset_date => Chronic.parse('today'), 
                       :disease => {}, 
                       :lab_result => {},
                       :active_patient => { :active_primary_entity => { :person => {}, 
                                                                        :entities_location => {}, 
                                                                        :address => {}, 
                                                                        :telephone => {} 
                                                                      }
                                          },
                       :active_hospital => { :hospitals_participation => {} }
                      )
                             
    prepopulate if !params[:from_search].nil?

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /event/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /event
  # POST /event.xml
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        flash[:notice] = 'CMR was successfully created.'
        format.html { redirect_to(cmr_url(@event)) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /event/1
  # PUT /event/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'CMR was successfully updated.'
        format.html { redirect_to(cmr_url(@event)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /event/1
  # DELETE /event/1.xml
  def destroy
    #TODO: Make this a soft delete.  Currently orphans all children
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(cmrs_url) }
      format.xml  { head :ok }
    end
  end

  def associations
    @event = Event.find(params[:id])
    @people = find_unassociated_people
  end

  def add_association
    @event = Event.find(params[:id])
    association = Participation.new
    association.primary_entity_id = params[:person]
    respond_to do |format|
      if @event.participations << association
        flash[:notice] = 'Association has been added.'
        format.html { redirect_to(cmr_url(@event)) }
      else
        @people = find_unassociated_people
        format.html { render :action => "associations" }
      end
    end
  end

  def find_unassociated_people
    # If I weren't gonna rip this out, I'd do it in SQL
    all_people = PersonEntity.find_all
    participants = @event.participations.map { |p| p.person_entity.id }
    all_people.select { |p| not participants.include?(p.id) }
  end
  
  private
  
  def prepopulate
    # Perhaps include a message if we know the names were split out of a full text search
    @event.active_patient.active_primary_entity.person.first_name = params[:first_name]
    @event.active_patient.active_primary_entity.person.last_name = params[:last_name]
    @event.active_patient.active_primary_entity.person.birth_date = params[:birth_date]
  end
  
end
