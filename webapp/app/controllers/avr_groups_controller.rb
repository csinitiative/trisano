class AvrGroupsController < AdminController

  def index
    @avr_groups = AvrGroup.all(:order => "name ASC")
  end

  def show
    @avr_group = AvrGroup.find(params[:id])
  end

  def new
    @avr_group = AvrGroup.new
  end

  def edit
    @avr_group = AvrGroup.find(params[:id])
  end

  def create
    @avr_group = AvrGroup.new(params[:avr_group])

    if @avr_group.save
      flash[:notice] = t("avr_group_successfully_created")
      redirect_to(@avr_group)
    else
      render :action => "new"
    end
  end
  
  def update
    @avr_group = AvrGroup.find(params[:id])

    if @avr_group.update_attributes(params[:avr_group])
      flash[:notice] = t("avr_group_successfully_updated")
      redirect_to(@avr_group)
    else
      render :action => "edit"
    end
  end

  def destroy
    @avr_group = AvrGroup.find(params[:id])
    @avr_group.destroy
    redirect_to(avr_groups_url)
  end

end