class SuscriptorsController < ApplicationController

  # GET /suscriptors
  # GET /suscriptors.xml
  def index
    @qbe_key = Suscriptor.new()
    #En base al qbe_key construido en la vista, se construye el qbe_select para el select...
    @qbe_select = build_qbe(params)

    sort = case params['sort']
    when "codigo"  then "codigo"
    when "nombre"  then "nombre"
    when "codigo_reverse"  then "codigo DESC"
    when "nombre_reverse"  then "nombre DESC"
    else  "codigo" # ordenamiento por omisiÃ³n
    end
    if  not @qbe_select.nil?
      @suscriptors = Suscriptor.paginate :page => params[:page], :order => sort, :conditions =>  @qbe_select
    else
      @suscriptors = Suscriptor.paginate :page => params[:page], :order => sort
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @suscriptors }
    end
  end

  # GET /suscriptors/1
  # GET /suscriptors/1.xml
  def show
    @suscriptor = Suscriptor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @suscriptor }
    end
  end

  # GET /suscriptors/new
  # GET /suscriptors/new.xml
  def new
    @suscriptor = Suscriptor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @suscriptor }
    end
  end

  # GET /suscriptors/1/edit
  def edit
    @suscriptor = Suscriptor.find(params[:id])
  end

  # POST /suscriptors
  # POST /suscriptors.xml
  def create
    @suscriptor = Suscriptor.new(params[:suscriptor])

    respond_to do |format|
      if @suscriptor.save
        flash[:notice] = nil
        format.html { redirect_to(suscriptors_url)}
        format.xml  { render :xml => @suscriptor, :status => :created, :location => @suscriptor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @suscriptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /suscriptors/1
  # PUT /suscriptors/1.xml
  def update
    @suscriptor = Suscriptor.find(params[:id])

    respond_to do |format|
      if @suscriptor.update_attributes(params[:suscriptor])
        flash[:notice] = nil
        format.html { redirect_to(suscriptors_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @suscriptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /suscriptors/1
  # DELETE /suscriptors/1.xml
  def destroy
    @suscriptor = Suscriptor.find(params[:id])
    @suscriptor.destroy

    respond_to do |format|
      format.html { redirect_to(suscriptors_url) }
      format.xml  { head :ok }
    end
  end

  def display_logo
    picture = Suscriptor.find(params[:id])
    send_data(picture.logo_img,:filename => picture.logo, :type => picture.logo_type, :dispoition => 'inline')
  end

end
