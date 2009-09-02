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
        format.html { redirect_to @organism  }
      else
        format.html { render :action => :new }
      end
    end
  end

end
