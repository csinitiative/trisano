class OrganismsController < AdminController
  before_filter :find_organism, :only => [:edit, :show, :update]

  def index
    @organisms = Organism.all
    respond_to do |format|
      format.html
      format.xml { render :xml => @organisms }
    end
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
        expire_fragment(%r{/events/})

        flash[:notice] = t("organism_created")
        format.html { redirect_to @organism  }
      else
        format.html { render :action => :new, :status => :bad_request }
      end
    end
  end

  def update
    params[:organism][:disease_ids] ||= [] if params[:organism]

    respond_to do |format|
      if @organism.update_attributes params[:organism]
        expire_fragment(%r{/events/})

        flash[:notice] = t("organism_updated")
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
