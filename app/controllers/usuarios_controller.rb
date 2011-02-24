class UsuariosController < ApplicationController

  # GET /usuarios
  # GET /usuarios.xml
  def index
    @qbe_key = Usuario.new()
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
      @usuarios = Usuario.paginate :page => params[:page], :order => sort, :conditions =>  @qbe_select
    else
      @usuarios = Usuario.paginate :page => params[:page], :order => sort
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @usuarios }
    end
  end

  # GET /usuarios/1
  # GET /usuarios/1.xml
  def show
    @usuario = Usuario.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @usuario }
    end
  end

  # GET /usuarios/new
  # GET /usuarios/new.xml
  def new
    @usuario = Usuario.new
    #Creamos al Rol asociado al Usuario...
    @rols_disp = Rol.find(:all, :order => 'id ASC') #Los roles disponibles...
    @rols_selec = [] #Los roles seleccionados...

    #@qbe_key = Rol.new()

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @usuario }
    end
  end

  # GET /usuarios/1/edit
  def edit
    @usuario = Usuario.find(params[:id])
    condiciones = @usuario.rol_ids
    @rols_disp = Rol.find(:all, :conditions => "id NOT IN (#{condiciones.join(",")})") #Los que no ha seleccionado...
    @rols_selec = @usuario.rols.find(:all, :conditions => [params[:id]]) #Los roles seleccionados...
  end

  # POST /usuarios
  # POST /usuarios.xml
  def create
    @usuario = Usuario.new(params[:usuario])
    @usuario.rol_list = params[:rols_buffer].split(",").map { |s| s.to_i }
    dummy = @usuario.rol_list.pop #El ultimo elemento siempre es cero por un defecto...

    error_flag = 0
    begin
      @usuario.save!
    rescue
      error_flag = 1
      @usuario.errors.add_to_base "Error guardando el registro!!!"
      @rols_disp = Rol.find(:all, :conditions => "id NOT IN (#{@usuario.rol_list.join(",")})")
      @rols_selec = Rol.find(@usuario.rol_list)
    end

    respond_to do |format|
      if error_flag == 0
        flash[:notice] = nil
        format.html { redirect_to(usuarios_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @usuario.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /usuarios/1
  # PUT /usuarios/1.xml
  def update
    @usuario = Usuario.find(params[:id])
    @usuario.rol_list = params[:rols_buffer].split(",").map { |s| s.to_i }
    dummy = @usuario.rol_list.pop #El ultimo elemento siempre es cero por un defecto...

    error_flag = 0
    begin
      @usuario.update_attributes!(params[:usuario])
    rescue
      error_flag = 1
      @usuario.errors.add_to_base "Error guardando el registro!!!"
      @rols_disp = Rol.find(:all, :conditions => "id NOT IN (#{@usuario.rol_list.join(",")})")
      @rols_selec = Rol.find(@usuario.rol_list)
    end

    respond_to do |format|
      if error_flag == 0
        flash[:notice] = nil
        format.html { redirect_to(usuarios_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @usuario.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /usuarios/1
  # DELETE /usuarios/1.xml
  def destroy
    @usuario = Usuario.find(params[:id])
    @usuario.destroy

    respond_to do |format|
      format.html { redirect_to(usuarios_url) }
      format.xml  { head :ok }
    end
  end


  def usuario_rol_selec #Mostramos los seleccionados
    condiciones = []
    params.each do |key, value|
      if key[0,7].eql?("rol_id_")
        condiciones << value
      end
    end

    @rols_selec = Rol.find(condiciones)
    render :partial => "rol_selec"
  end

  def usuario_rol_disp #Mostramos los que quedan por seleccionar
    condiciones = nil
    params.each do |key, value|
      if key[0,7].eql?("rol_id_")
        if condiciones.nil?
          condiciones = value
        else
          condiciones = condiciones + ',' + value
        end
      end
    end

    @rols_disp = Rol.find(:all, :conditions => "id NOT IN (#{condiciones})")
    render :partial => "rol_disp"
  end
end
