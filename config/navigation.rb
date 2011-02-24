SimpleNavigation::Configuration.run do |navigation|

  navigation.auto_highlight = true

  m = []
  i = 0
  
  navigation.items do |m[1]|
    if !session[:usuario_id].nil? && !session[:usuario_id].blank?
      while session[:menu][i][0] == 1 # 1 por m1... n por mn: esto es, procesamos la capa i del menu.
        if session[:menu][i][3][0].chr == "M"
          k = session[:menu][i][0] + 1
          m[1].item session[:menu][i][1], session[:menu][i][2], "/admin/entrada" do |m[k]|
            i = recorre_menu(session[:menu][i][3], m[k], k, i + 1)
          end
        else
          m[1].item session[:menu][i][1], session[:menu][i][2], session[:menu][i][3]
        end
        i = i + 1
      end
    end
    m[1].item :logout, 'Salida del Sistema', :controller => 'admin', :action => 'logout'
  end

end
