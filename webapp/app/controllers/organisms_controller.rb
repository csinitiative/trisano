class OrganismsController < AdminController

  def show
    @organism = Organism.find params[:id]
  end

end
