# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => :login
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery :secret => '8fc080370e56e929a2d5afca5540a0f7'

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def params_check(*args) 
    #Usage
    #if params[:object] && !params[:object].empty -->
    #   if params_check(:object)
    #if params[:object] && params[:object] == value -->
    #   if params_check(:object, value)
    #if params[:object][:attribute] && !params[:object][:attribute].empty -->
    #   if params_check([:object, :attribute])
    #if params[:object][:attribute] && params[:object][:attribute] == value -->
    #   if params_check([:object, :attribute], value)

    if args.length == 1
      if args[0].class == Array
        if params[args[0][0]][args[0][1]] && !params[args[0][0]][args[0][1]].empty?
          true
        end
      else        
        if params[args[0]] && !params[args[0]].empty?
          true
        end
      end
    elsif args.length == 2
      if args[0].class == Array
        if params[args[0][0]][args[0][1]] && params[args[0][0]][args[0][1]] == args[1]
          true
        end
      else
        if params[args[0]] && params[args[0]] == args[1]
          true
        end
      end  
    end
  end
  
  def format_date_string_DMY_to_YMD(*args) 
    if args.length == 1
      re1 = /(\d{1,2})[.-\/](\d{1,2})[.-\/](\d{2,4})/ #dd/mm/yyy
      date_d = args[0][re1,1]
      date_m = args[0][re1,2]
      date_y = args[0][re1,3]
      if date_y.blank? 
        re1 = /(\d{1,2})[.-\/](\d{2,4})/ #mm/yyyy
        date_m = args[0][re1,1]
        date_y = args[0][re1,2] 
        if date_y.blank?
          re1 = /(\d{2,4})/ #yyyy
          date_y = args[0][re1,1]
          if date_y.blank?
            return '*'
          else
            return ( date_y + "*" ) #yyyy*
          end
        else
          return ( date_y + "/" + date_m + "/*" ) #yyyy/mm* TODO: No parece funcionar en MySQL...
        end
      else
        return ( date_y + "/" + date_m + "/" + date_d ) #yyy/mm/dd
      end
    end
  end
  
  def build_qbe(*args)
    qbe_select = nil
    args[0].each do |key, value|
      if @qbe_key.attribute_names().include?(key) #Con esto, solo vemos los argumentos propios a la clase...
        if not value.blank?
          if key.include?('fecha') #Si estamos evaluando una fecha... queremos convertirla en formato :DB
            value1 = format_date_string_DMY_to_YMD(value)
          else
            value1 = value
          end
          value2 = value1
          #          if value1.include?('*') #Si se especifica * en un campo del QBE, queremos reemplazarlo por un % para el "like"...
          oper = ' like ' #TODO: oper se debe poder especificar en el QBE...
          value1 = value1.sub(/[*]/, '%')
          #          else
          #            oper = ' = '
          #          end
          if qbe_select.nil?
            qbe_select =  key + oper +  "'" + value1 + "%'"
            @qbe_key[key] = value2 #Es mejor usar "value2" para asignar adecuadamente el formato de la fecha...
          else
            qbe_select = qbe_select + " and " + key + oper  + "'" + value1 + "%'"
            @qbe_key[key] = value2 #Es mejor usar "value2" para asignar adecuadamente el formato de la fecha...
          end
        end
      end
    end
    if args[1] && !args[1].nil? && args[2] && !args[2].nil? # se está pasanso un segundo y tercer parámetro...
      if qbe_select.nil?# Se desea que Index típicamente filtre por compañía....
        qbe_select = "#{args[1]} = #{args[2]}"
      else
        qbe_select = qbe_select + "and #{args[1]} = #{args[2]}"
      end
    end
    return qbe_select
  end

  protected

  def authorize
    unless Usuario.find_by_id(session[:usuario_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Debe ingresar haciendo login en el sistema..."
      redirect_to :controller => 'admin', :action =>  'login'
    else
      flash[:notice] = nil
    end
  end
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

end
