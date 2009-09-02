class OrganismsController < AdminController

  def show
    @organism = Organism.find params[:id]
  end

  def new
    @organism = Organism.new
  end

  def create
    @organism = Organism.new(params[:organism])

    respond_to do |format|
      if @organism.save
        flash[:notice] = 'Organism was successfully created'
        format.html { redirect_to @organism  }
      else
        format.html { render :action => :new, :status => :bad_request }
      end
    end
  end

end
