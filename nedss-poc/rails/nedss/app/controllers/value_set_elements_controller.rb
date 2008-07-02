class ValueSetElementsController < ApplicationController

  def index
    @value_set_elements = ValueSetElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @value_set_elements }
    end
  end

  def show
    @value_set_element = ValueSetElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @value_set_element }
    end
  end

  def new
    begin
      @value_set_element = ValueSetElement.new
      @value_set_element.parent_element_id = params[:form_element_id]
      @value_set_element.form_id = params[:form_id]
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the value set form at this time.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @value_set_element = ValueSetElement.find(params[:id])
  end

  def create
    @value_set_element = ValueSetElement.new(params[:value_set_element])

    respond_to do |format|
      if @value_set_element.save_and_add_to_form(params[:value_set_element][:parent_element_id])
        format.xml  { render :xml => @value_set_element, :status => :created, :location => @value_set_element }
        format.js { @form = Form.find(@value_set_element.form_id)}
      else
        format.xml  { render :xml => @value_set_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  def update
    
    params[:value_set_element][:existing_value_element_attributes] ||= {}
    
    @value_set_element = ValueSetElement.find(params[:id])

    respond_to do |format|
      if @value_set_element.update_attributes(params[:value_set_element])
        format.html { redirect_to(@value_set_element) }
        format.xml  { head :ok }
        format.js { @form = Form.find(@value_set_element.form_id)}
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @value_set_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "edit" }
      end
    end
  end

  def destroy
    @value_set_element = ValueSetElement.find(params[:id])
    @value_set_element.destroy

    respond_to do |format|
      format.html { redirect_to(value_set_elements_url) }
      format.xml  { head :ok }
    end
  end
  
  # Debt: Maybe this should move to a value_controller. Putting here for expediency.
  def toggle_value
    begin
      @value_element = ValueElement.find(params[:value_element_id])
      @value_element.toggle(:is_active)
      @value_element.save!
      @form = Form.find(@value_element.form_id)
    rescue Exception => ex
      p ex
      logger.debug ex
      flash[:notice] = 'Unable to toggle the value at this time.'
      render :template => 'rjs-error'
    end
  end
  
end
