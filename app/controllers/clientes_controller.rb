class ClientesController < ApplicationController

  # GET /clientes  
  # GET /clientes.xml  
  def index
    @qbe_key = Cliente.new() 
    #En base al qbe_key construido en la vista, se construye el qbe_select para el select...
    @qbe_select = build_qbe(params, :suscriptor_id, session[:suscriptor_id])

    sort = case params['sort']
    when "codigo"  then "codigo"
    when "nombre"  then "nombre"
    when "codigo_reverse"  then "codigo DESC"
    when "nombre_reverse"  then "nombre DESC"
    else  "codigo" # ordenamiento por omisión
    end
    if  not @qbe_select.nil?
      @clientes = Cliente.paginate :page => params[:page], :order => sort, :conditions =>  @qbe_select
    else
      @clientes = Cliente.paginate :page => params[:page], :order => sort
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clientes }
    end
  end

  # GET /clientes/1
  # GET /clientes/1.xml
  def show
    @cliente = Cliente.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cliente }
    end
  end

  # GET /clientes/1/panel
  def panel
    @cliente = Cliente.find(params[:id])
    @proyectos = Proyecto.find(:all, :conditions => ":cliente_id =" + @cliente.id)

    respond_to do |format|
      format.html # panel.html.erb
      format.xml  { render :xml => @cliente }
    end
  end

  # GET /clientes/new
  # GET /clientes/new.xml
  def new
    @cliente = Cliente.new
    @cliente.suscriptor_id = session[:suscriptor_id]
    @cliente.logo = "NoLogo.jpg"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cliente }
    end
  end

  # GET /clientes/1/edit
  def edit
    @cliente = Cliente.find(params[:id])
  end

  # POST /clientes
  # POST /clientes.xml
  def create
    @cliente = Cliente.new(params[:cliente])

    respond_to do |format|
      if @cliente.save
        flash[:notice] = nil
        format.html { redirect_to(clientes_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cliente.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clientes/1
  # PUT /clientes/1.xml
  def update
    @cliente = Cliente.find(params[:id])

    respond_to do |format|
      if @cliente.update_attributes(params[:cliente])
        flash[:notice] = nil
        format.html { redirect_to(clientes_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cliente.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clientes/1
  # DELETE /clientes/1.xml
  def destroy
    @cliente = Cliente.find(params[:id])
    @cliente.destroy

    respond_to do |format|
      format.html { redirect_to(clientes_url) }
      format.xml  { head :ok }
    end
  end

  def display_logo
    picture = Cliente.find(params[:id])
    send_data(picture.logo_img,:filename => picture.logo, :type => picture.logo_type, :dispoition => 'inline')
  end
    
end
