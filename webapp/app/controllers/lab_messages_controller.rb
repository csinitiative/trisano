class LabMessagesController < ApplicationController
  # GET /lab_messages
  # GET /lab_messages.xml
  def index
    @lab_messages = LabMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lab_messages }
    end
  end

  # GET /lab_messages/1
  # GET /lab_messages/1.xml
  def show
    @lab_message = LabMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lab_message }
    end
  end

  # GET /lab_messages/new
  # GET /lab_messages/new.xml
  def new
    @lab_message = LabMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lab_message }
    end
  end

  # GET /lab_messages/1/edit
  def edit
    @lab_message = LabMessage.find(params[:id])
  end

  # POST /lab_messages
  # POST /lab_messages.xml
  def create
    @lab_message = LabMessage.new(params[:lab_message])

    respond_to do |format|
      if @lab_message.save
        flash[:notice] = 'Lab message was successfully created.'
        format.html { redirect_to(@lab_message) }
        format.xml  { render :xml => @lab_message, :status => :created, :location => @lab_message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lab_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lab_messages/1
  # PUT /lab_messages/1.xml
  def update
    @lab_message = LabMessage.find(params[:id])

    respond_to do |format|
      if @lab_message.update_attributes(params[:lab_message])
        flash[:notice] = 'Lab message was successfully updated.'
        format.html { redirect_to(@lab_message) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lab_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lab_messages/1
  # DELETE /lab_messages/1.xml
  def destroy
    @lab_message = LabMessage.find(params[:id])
    @lab_message.destroy

    respond_to do |format|
      format.html { redirect_to(lab_messages_url) }
      format.xml  { head :ok }
    end
  end
end
