class RolsController < ApplicationController

  # GET /rols
  # GET /rols.xml
  def index
    @qbe_key = Rol.new()
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
      @rols = Rol.paginate :page => params[:page], :order => sort, :conditions =>  @qbe_select
    else
      @rols = Rol.paginate :page => params[:page], :order => sort
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rols }
    end
  end

  # GET /rols/1
  # GET /rols/1.xml
  def show
    @rol = Rol.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rol }
    end
  end

  # GET /rols/new
  # GET /rols/new.xml
  def new
    @rol = Rol.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rol }
    end
  end

  # GET /rols/1/edit
  def edit
    @rol = Rol.find(params[:id])
  end

  # POST /rols
  # POST /rols.xml
  def create
    @rol = Rol.new(params[:rol])

    respond_to do |format|
      if @rol.save
        flash[:notice] = nil
        format.html { redirect_to(rols_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rol.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rols/1
  # PUT /rols/1.xml
  def update
    @rol = Rol.find(params[:id])

    respond_to do |format|
      if @rol.update_attributes(params[:rol])
        flash[:notice] = nil
        format.html { redirect_to(rols_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rol.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rols/1
  # DELETE /rols/1.xml
  def destroy
    @rol = Rol.find(params[:id])
    @rol.destroy

    respond_to do |format|
      format.html { redirect_to(rols_url) }
      format.xml  { head :ok }
    end
  end
end
