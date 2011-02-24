class AdminController < ApplicationController
  def login
    #TODO: Mejorar esta inicializacion!!!!
    session[:usuario_id] = nil
    session[:suscriptor_id] = nil
    session[:usuario_conectado] = nil
    flash.now[:error] = nil

    if request.post?
      usuario = Usuario.authenticate(params[:login], params[:password])
      if usuario
        session[:usuario_id] = usuario.id
        session[:usuario_conectado] = usuario.nombre + '/' + usuario.suscriptor.codigo
        session[:login] = params[:login]
        session[:suscriptor_id] = usuario.suscriptor_id # Determina la compañía para todos los acceso de esta sesion...
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || {:action => "entrada"})
      else
        flash.now[:notice] = "Combinación invalidad de usuario y password."
      end
    end


  end

  def entrada
    unless Usuario.find_by_id(session[:usuario_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Debe ingresar haciendo login en el sistema..."
      redirect_to :controller => 'admin', :action =>  'login'
    else
      flash[:notice] = nil
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def logout
    session[:usuario_id] = nil
    session[:suscriptor_id] = nil
    session[:original_uri] = nil
    session[:usuario_conectado] = nil
    flash[:error] = nil
    flash[:notice] = "Desconectado del Sistema"
    redirect_to(:action => "login")
  end
end