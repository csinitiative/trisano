class FormsController < ApplicationController
  # GET /forms
  # GET /forms.xml
  def index
    @forms = Form.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forms }
    end
  end

  # GET /forms/1
  # GET /forms/1.xml
  def show
    @form = Form.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @form }
    end
  end

  # GET /forms/new
  # GET /forms/new.xml
  def new
    @form = Form.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @form }
    end
  end

  # GET /forms/1/edit
  def edit
    @form = Form.find(params[:id])
  end

  # POST /forms
  # POST /forms.xml
  def create
    @form = Form.new(params[:form])

    respond_to do |format|
      if @form.save
        flash[:notice] = 'Form was successfully created.'
        format.html { redirect_to(@form) }
        format.xml  { render :xml => @form, :status => :created, :location => @form }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forms/1
  # PUT /forms/1.xml
  def update
    @form = Form.find(params[:id])

    respond_to do |format|
      if @form.update_attributes(params[:form])
        flash[:notice] = 'Form was successfully updated.'
        format.html { redirect_to(@form) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forms/1
  # DELETE /forms/1.xml
  def destroy
    @form = Form.find(params[:id])
    @form.destroy

    respond_to do |format|
      format.html { redirect_to(forms_url) }
      format.xml  { head :ok }
    end
  end
  
  def builder
    @form = Form.find(params[:id])

    respond_to do |format|
      format.html { render :template => "forms/builder", :layout => "builder" }
    end
  end
  
  def section_sort
    @sections = Section.find_all_by_form_id(params[:id], :order => :position)
    
    @sections.each do |section|
      section.position = params['section-list'].index(section.id.to_s) + 1
      section.save!
    end
    
    render :text => "<span style='color: green'>Section sort successful</span>"
  end
  
  def short_section_new
    @section = Section.new(:form_id => params[:id])
  end
  
  def short_section_edit
    @section = Section.find(params[:id])
  end
  
  #
  # Investigator form handling -- maybe bust these out as a separate controller or resource
  #
  
  def display_form
    @form = Form.find(params[:id])
    
    # Temporary
    @responses = ""

    respond_to do |format|
      format.html { render :template => "forms/display", :layout => "display" }
    end
  end
  
  def process_form
    Form.save_responses(params)
    
    respond_to do |format|
      format.html { render :text => "Success"}
    end
  end
  
  def edit_form
    @form = Form.find(params[:id])
    @responses = Response.find_all_by_form_id_and_cmr_id(params[:id], params[:cmr_id])
    
    respond_to do |format|
      format.html { render :template => "forms/display", :layout => "display" }
    end
  end
  
end
