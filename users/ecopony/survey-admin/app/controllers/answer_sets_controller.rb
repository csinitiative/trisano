class AnswerSetsController < ApplicationController
  # GET /answer_sets
  # GET /answer_sets.xml
  def index
    @answer_sets = AnswerSet.find(:all, :order => :id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @answer_sets }
    end
  end

  # GET /answer_sets/1
  # GET /answer_sets/1.xml
  def show
    @answer_set = AnswerSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @answer_set }
    end
  end

  # GET /answer_sets/new
  # GET /answer_sets/new.xml
  def new
    @answer_set = AnswerSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @answer_set }
    end
  end

  # GET /answer_sets/1/edit
  def edit
    @answer_set = AnswerSet.find(params[:id])
  end

  # POST /answer_sets
  # POST /answer_sets.xml
  def create
    @answer_set = AnswerSet.new(params[:answer_set])

    respond_to do |format|
      if @answer_set.save
        flash[:notice] = 'AnswerSet was successfully created.'
        format.html { redirect_to(@answer_set) }
        format.xml  { render :xml => @answer_set, :status => :created, :location => @answer_set }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @answer_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /answer_sets/1
  # PUT /answer_sets/1.xml
  def update
    @answer_set = AnswerSet.find(params[:id])

    respond_to do |format|
      if @answer_set.update_attributes(params[:answer_set])
        flash[:notice] = 'AnswerSet was successfully updated.'
        format.html { redirect_to(@answer_set) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @answer_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /answer_sets/1
  # DELETE /answer_sets/1.xml
  def destroy
    @answer_set = AnswerSet.find(params[:id])
    @answer_set.destroy

    respond_to do |format|
      format.html { redirect_to(answer_sets_url) }
      format.xml  { head :ok }
    end
  end
end
