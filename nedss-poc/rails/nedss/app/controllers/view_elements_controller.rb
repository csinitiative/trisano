class ViewElementsController < ApplicationController

  def index
    @view_elements = ViewElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @view_elements }
    end
  end

  def show
    @view_element = ViewElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @view_element }
    end
  end
  
  def new
    begin
      @view_element = ViewElement.new
      @view_element.form_id = params[:form_id]
    rescue Exception => ex
      logger.debug ex
      flash[:notice] = 'Unable to display the tab form at this time.'
      render :template => 'rjs-error'
    end
  end

  def edit
    @view_element = ViewElement.find(params[:id])
  end
    
  def create
    @view_element = ViewElement.new(params[:view_element])

    respond_to do |format|
      if @view_element.save_and_add_to_form
        flash[:notice] = 'Tab was successfully created.'
        format.xml  { render :xml => @view_element, :status => :created, :location => @view_element }
        format.js { @form = Form.find(@view_element.form_id)}
      else
        format.xml  { render :xml => @view_element.errors, :status => :unprocessable_entity }
        format.js { render :action => "new" }
      end
    end
  end

  def update
    @view_element = ViewElement.find(params[:id])

    respond_to do |format|
      if @view_element.update_attributes(params[:view_element])
        flash[:notice] = 'ViewElement was successfully updated.'
        format.html { redirect_to(@view_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @view_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @view_element = ViewElement.find(params[:id])
    @view_element.destroy

    respond_to do |format|
      format.html { redirect_to(view_elements_url) }
      format.xml  { head :ok }
    end
  end
end
