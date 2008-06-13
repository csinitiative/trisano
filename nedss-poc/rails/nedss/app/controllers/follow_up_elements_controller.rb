class FollowUpElementsController < ApplicationController

  def index
    @follow_up_elements = FollowUpElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @follow_up_elements }
    end
  end

  def show
    @follow_up_element = FollowUpElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @follow_up_element }
    end
  end
  
  def new
    begin
      @follow_up_element = FollowUpElement.new
      @follow_up_element.parent_element_id = params[:form_element_id]
      @follow_up_element.core_data = params[:core_data]
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the follow up form at this time.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @follow_up_element = FollowUpElement.find(params[:id])
  end
  
  def create
    @follow_up_element = FollowUpElement.new(params[:follow_up_element])

    respond_to do |format|
      if @follow_up_element.save_and_add_to_form
        flash[:notice] = 'Follow up container was successfully created.'
        format.xml  { render :xml => @follow_up_element, :status => :created, :location => @follow_up_element }
        format.js { @form = Form.find(@follow_up_element.form_id)}
      else
        format.xml  { render :xml => @follow_up_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end


  def update
    @follow_up_element = FollowUpElement.find(params[:id])

    respond_to do |format|
      if @follow_up_element.update_attributes(params[:follow_up_element])
        flash[:notice] = 'FollowUpElement was successfully updated.'
        format.html { redirect_to(@follow_up_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @follow_up_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @follow_up_element = FollowUpElement.find(params[:id])
    @follow_up_element.destroy

    respond_to do |format|
      format.html { redirect_to(follow_up_elements_url) }
      format.xml  { head :ok }
    end
  end
  
  def process_core_condition
    begin
      @follow_ups = FollowUpElement.process_core_condition(params)
      @event = params[:event_id].blank? ? Event.new : Event.find(params[:event_id])
    rescue Exception => ex
      logger.info ex
      flash[:notice] = 'Unable to process conditional logic for follow up questions.'
      render :template => 'rjs-error'
    end
    
    
  end
  
end
