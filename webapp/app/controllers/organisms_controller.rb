class OrganismsController < AdminController
  before_filter :find_organism, :only => [:edit, :show, :update]

  def index
    @organisms = Organism.all
  end

  def show
  end

  def edit
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

  def update
    respond_to do |format|
      if @organism.update_attributes params[:organism]
        flash[:notice] = 'Organism was successfully updated.'
        format.html { redirect_to @organism }
      else
        format.html { render :action => :edit, :status => :bad_request }
      end
    end
  end

  private

  def find_organism
    @organism = Organism.find params[:id]
  end
end
