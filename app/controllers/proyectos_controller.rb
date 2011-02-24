class ProyectosController < ApplicationController

  before_filter :localize_date, :only => [:update, :create ]
  def localize_date
    params[:proyecto][:fecha_inicio_original].gsub!(/[.\/]/,'-')
    params[:proyecto][:fecha_inicio_actual].gsub!(/[.\/]/,'-')
    params[:proyecto][:fecha_inicio_real].gsub!(/[.\/]/,'-')
    params[:proyecto][:fecha_fin_original].gsub!(/[.\/]/,'-')
    params[:proyecto][:fecha_fin_actual].gsub!(/[.\/]/,'-')
    params[:proyecto][:fecha_fin_real].gsub!(/[.\/]/,'-')

  end

  # GET /proyectos
  # GET /proyectos.xml
  def index

    @qbe_key = Proyecto.new() 
    #En base al qbe_key construido en la vista, se construye el qbe_select para el select...
    @qbe_select = build_qbe(params, :suscriptor_id, session[:suscriptor_id])

    sort = case params['sort']
    when "codigo"  then "codigo"
    when "nombre"  then "nombre"
    when "codigo_reverse"  then "codigo DESC"
    when "nombre_reverse"  then "nombre DESC"
    else  "codigo" # ordenamiento por omisiÃ³n
    end

    if  not @qbe_select.nil?
      @proyectos = Proyecto.paginate :page => params[:page],  :order => sort, :conditions =>  @qbe_select
    else
      @proyectos = Proyecto.paginate :page => params[:page],  :order => sort
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @proyectos }
    end
  end

  # GET /proyectos/1
  # GET /proyectos/1.xml
  def show
    @proyecto = Proyecto.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @proyecto }
    end
  end

  # GET /proyectos/new
  # GET /proyectos/new.xml
  def new
    @proyecto = Proyecto.new
    @proyecto.suscriptor_id = session[:suscriptor_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @proyecto }
    end
  end

  # GET /proyectos/1/edit
  def edit
    @proyecto = Proyecto.find(params[:id])
  end

  # POST /proyectos
  # POST /proyectos.xml
  def create
    @proyecto = Proyecto.new(params[:proyecto])

    respond_to do |format|
      if @proyecto.save
        flash[:notice] = nil
        format.html { redirect_to(proyectos_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @proyecto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /proyectos/1
  # PUT /proyectos/1.xml
  def update
    @proyecto = Proyecto.find(params[:id])
    
    respond_to do |format|
      if @proyecto.update_attributes(params[:proyecto])
        flash[:notice] = nil
        format.html { redirect_to(proyectos_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @proyecto.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /proyectos/1
  # DELETE /proyectos/1.xml
  def destroy
    @proyecto = Proyecto.find(params[:id])
    @proyecto.destroy

    respond_to do |format|
      format.html { redirect_to(proyectos_url) }
      format.xml  { head :ok }
    end
  end
end
