module JqgridUtilities
  include	ActionView::Helpers::JavaScriptHelper unless self.respond_to?("escape_javascript")
  def gen_columns(columns)
    # Generate columns data
    col_names = "[" # Labels
    col_model = "[" # Options
    columns.each do |c|
      col_names << "'#{c[:label]}',"
      col_model << "{name:'#{c[:field]}', index:'#{c[:field]}'#{get_attributes(c)}, hidden:#{c[:hidden] || 'false'}},"
    end
    col_names.chop! << "]"
    col_model.chop! << "]"
    [col_names, col_model]
  end

  # Generate a list of attributes for related column (align:'right', sortable:true, resizable:false, ...)
  def get_attributes(column)
    options = ","
    column.except(:field, :label, :hidden).each do |couple|
      if couple[1].instance_of?(Hash) # covers editoptions, formoptions, searchoptions, editrules
        options << "#{couple[0]}:#{get_sub_options(couple[1])},"
        # need to pass a string function name but result can't be surrounded in quotes
      elsif couple[0] == :format_function || couple[0] == :formatter_function
        options << "formatter:#{couple[1]},"
      elsif couple[0] == :unformat_function || couple[0] == :unformatter_function
        options << "unformat:#{couple[1]},"
      else
        case couple[1]
          when String
            options << "#{couple[0]}:'#{couple[1]}',"
          when Hash
            options << %Q/#{couple[0]}:/
            options << get_sub_options(couple[1])
            options << ","
          else
            options << "#{couple[0]}:#{couple[1]},"
        end
      end
    end
    options.chop!
  end

  # Generate options for editable fields (value, data, width, maxvalue, cols, rows, ...)
  def get_sub_options(editoptions)
    options = "{"
    editoptions.each do |couple|
      if couple[0] == :value # :value => [[1, "Rails"], [2, "Ruby"], [3, "jQuery"]]
        options << %Q/value:"/
        case couple[1][0]
          when Array
            couple[1].each do |v|
              options << "#{v[0]}:#{v[1]};"
            end
          when Hash
            options << get_sub_options(couple[1])
          else
            options << "#{couple[1][0]}:#{couple[1][1]};"
        end
        options.chop! << %Q/",/
      elsif couple[0] == :data # :data => [Category.all, :id, :title])
        options << %Q/value:"/
        couple[1].first.each do |obj|
          options << "%s:%s;" % [obj.send(couple[1].second), obj.send(couple[1].third)]
        end
        options.chop! << %Q/",/
      else # :size => 30, :rows => 5, :maxlength => 20, ...
        if couple[1].instance_of?(Fixnum) || couple[1] == 'true' || couple[1] == 'false' || couple[1] == true || couple[1] == false
          if couple[0] == :defaultValue #need to quote true and false strings for defaultValue or get error
            options << %Q/#{couple[0]}:'#{couple[1]}',/
          else
            options << %Q/#{couple[0]}:#{couple[1]},/
          end
        else
          options << %Q/#{couple[0]}:"#{couple[1]}",/            
        end
      end
    end
    options.chop! << "}"
  end
end # End JqgridUtilities Module


module Jqgrid
    include JqgridUtilities
    @@jrails_present = false
    mattr_accessor :jrails_present

    def jqgrid_stylesheets
			css = ""
      css << stylesheet_link_tag('jqgrid/jquery-ui-1.7.1.custom.css') + "\n" unless Jqgrid.jrails_present
      css << stylesheet_link_tag('jqgrid/ui.jqgrid.css') + "\n"
    end

    def jqgrid_javascripts
      locale = I18n.locale rescue :en

			js = []
			unless Jqgrid.jrails_present
				js << 'jquery.min'
				js << 'jquery-ui-1.7.1.custom.min'
			end
			js << 'jquery.layout'
			js << "i18n/grid.locale-#{locale}"
			js << "jquery.jqGrid.min"
			# js << "jquery.tablednd"
			# js << "jquery.contextmenu"
			js << "jqPersist"
			
			javascript_include_tag js.map {|f| "jqgrid/#{f}.js"}, :cache => "_jqgrid.js"
    end

    def jqgrid(title, id, action, columns = [], options = {})
      
      # Default options
      options = 
        { 
          :rows_per_page       => '10',
          :sort_column         => '',
          :sort_order          => '',
          :gridview            => 'false',
          :error_handler       => 'null',
          :inline_edit_handler => 'null',
          :double_click_handler => 'null',
          :add                 => 'false',
          :delete              => 'false',
          :search              => 'true',
          :edit                => 'false',          
          :inline_edit         => 'false',
          :autowidth           => 'false',
          :rownumbers          => 'false'                    
        }.merge(options)
      
      # Stringify options values
      options.inject({}) do |options, (key, value)|
        options[key] = (key != :subgrid && key != :custom_buttons && !value.instance_of?(Hash)) ? value.to_s : value
        options
      end
      
      options[:error_handler_return_value] = (options[:error_handler] == 'null') ? 'true;' : options[:error_handler]
      edit_button = (options[:edit].to_s == 'true' && options[:inline_edit].to_s != 'true').to_s

      # Generate columns data
      col_names, col_model = gen_columns(columns)

      # Enable filtering (by default)
      search = ""
      filter_toolbar = ""
      if options[:search] == 'true'
        search = %Q/.navButtonAdd("##{id}_pager",{caption:"#{options[:search_caption] || ""}",title:"Toggle Search Toolbar", buttonicon :'#{options[:search_icon] || 'ui-icon-search'}', onClickButton:function(){ mygrid#{id.titlecase}[0].toggleToolbar() } })/
        filter_toolbar = "mygrid#{id.titlecase}.filterToolbar();"
        filter_toolbar << "mygrid#{id.titlecase}[0].toggleToolbar()"
      end

      # Enable post_data array for appending to each request
      # :post_data => {'_search' => 1, : :myfield => 2}
      post_data = ""
      if options[:post_data]
        post_data = %Q/postData: #{get_sub_options(options[:post_data])},/
      end
      
      # Enable multi-selection (checkboxes)
      multiselect = "multiselect: false,"
      if options[:multi_selection]
        multiselect = "multiselect: true,"
        multihandler = %Q/
          jQuery("##{id}_select_button").click( function() { 
            var s; s = jQuery("##{id}").getGridParam('selarrrow'); 
            #{options[:selection_handler]}(s); 
            return false;
          });/
      end

      # Enable master-details
      masterdetails = ""
      if options[:master_details]
        masterdetails = %Q/
          onSelectRow: function(ids) { 
            if(ids == null) { 
              ids=0; 
              if(jQuery("##{id}_details").getGridParam('records') >0 ) 
              { 
                jQuery("##{id}_details").setGridParam({url:"#{options[:details_url]}?q=1&id="+ids,page:1})
                .setCaption("#{options[:details_caption]}: "+ids)
                .trigger('reloadGrid'); 
              } 
            } 
            else 
            { 
              jQuery("##{id}_details").setGridParam({url:"#{options[:details_url]}?q=1&id="+ids,page:1})
              .setCaption("#{options[:details_caption]} : "+ids)
              .trigger('reloadGrid'); 
            } 
          },/
      end

      # Enable selection link, button
      # The javascript function created by the user (options[:selection_handler]) will be called with the selected row id as a parameter
      selection_link = ""
      if options[:direct_selection].blank? && options[:selection_handler].present? && options[:multi_selection].blank?
        selection_link = %Q/
        jQuery("##{id}_select_button").click( function(){ 
          var id = jQuery("##{id}").getGridParam('selrow'); 
          if (id) { 
            #{options[:selection_handler]}(id); 
          } else { 
            alert("Please select a row");
          }
          return false; 
        });/
      end

      # Enable direct selection (when a row in the table is clicked)
      # The javascript function created by the user (options[:selection_handler]) will be called with the selected row id as a parameter
      direct_link = ""
      if options[:direct_selection] && options[:selection_handler].present? && options[:multi_selection].blank?
        direct_link = %Q/
        onSelectRow: function(id){ 
          if(id){ 
            #{options[:selection_handler]}(id); 
          } 
        },/
      end

      # doubleclick
      double_click = ""
      if options[:double_click_handler].present?
        double_click = %Q/
        ondblClickRow: function(id){ 
          #{options[:double_click_handler]}(id);
        },
        / 
      end
      
      
      # Enable grid_loaded callback
      # When data are loaded into the grid, call the Javascript function options[:grid_loaded] (defined by the user)
      grid_loaded = ""
      if options[:grid_loaded].present?
        grid_loaded = %Q/
        loadComplete: function(xhr){ 
          #{options[:grid_loaded]}(this, xhr);
        },
        /
      end

			options[:serializeGridData] = :persistGridState if options[:persistGridState]
			
			other_events = ""
			%w(loadBeforeSend loadCompleted serializeGridData).each do |event|
				if options[event.to_sym].present?
					other_events << "#{event}: #{options[event.to_sym]}, "
				end
			end

      # Enable inline editing
      # When a row is selected, all fields are transformed to input types
      editable = ""
      if options[:edit].to_s == 'true' && options[:inline_edit].to_s == 'true'
        editable = %Q/
        onSelectRow: function(id){ 
          if(id && id!==lastsel){ 
            jQuery('##{id}').restoreRow(lastsel);
            jQuery('##{id}').editRow(id, true, #{options[:inline_edit_handler]}, #{options[:error_handler]});
            lastsel=id; 
          } 
        },/
      end
      
      # Enable subgrids
      subgrid = ""
      subgrid_enabled = "subGrid:false,"

      if options[:subgrid].present?
        
        subgrid_enabled = "subGrid:true,"
        
        options[:subgrid] = 
          {
            :rows_per_page => '10',
            :sort_column   => 'id',
            :sort_order    => 'asc',
            :add           => 'false',
            :edit          => 'false',
            :delete        => 'false',
            :search        => 'false'
          }.merge(options[:subgrid])

        # Stringify options values
        options[:subgrid].inject({}) do |suboptions, (key, value)|
          suboptions[key] = value.to_s
          suboptions
        end
        
        subgrid_inline_edit = ""
        if options[:subgrid][:inline_edit] == true
          options[:subgrid][:edit] = 'false'
          subgrid_inline_edit = %Q/
          onSelectRow: function(id){ 
            if(id && id!==lastsel){ 
              jQuery('#'+subgrid_table_id).restoreRow(lastsel);
              jQuery('#'+subgrid_table_id).editRow(id,true); 
              lastsel=id; 
            } 
          },
          /
        end
          
        if options[:subgrid][:direct_selection] && options[:subgrid][:selection_handler].present?
          subgrid_direct_link = %Q/
          onSelectRow: function(id){ 
            if(id){ 
              #{options[:subgrid][:selection_handler]}(id); 
            } 
          },
          /
        end     
        
        sub_col_names, sub_col_model = gen_columns(options[:subgrid][:columns])
        
        subgrid = %Q(
        subGridRowExpanded: function(subgrid_id, row_id) {
        		var subgrid_table_id, pager_id;
        		subgrid_table_id = subgrid_id+"_t";
        		pager_id = "p_"+subgrid_table_id;
        		jQuery("#"+subgrid_id).html("<table id='"+subgrid_table_id+"' class='scroll'></table><div id='"+pager_id+"' class='scroll'></div>");
        		jQuery("#"+subgrid_table_id).jqGrid({
        			url:"#{options[:subgrid][:url]}?q=2&id="+row_id,
              editurl:'#{options[:subgrid][:edit_url]}?parent_id='+row_id,                            
        			datatype: "json",
        			colNames: #{sub_col_names},
        			colModel: #{sub_col_model},
        		   	rowNum:#{options[:subgrid][:rows_per_page]},
        		   	pager: pager_id,
        		   	imgpath: '/images/jqgrid',
        		   	sortname: '#{options[:subgrid][:sort_column]}',
        		    sortorder: '#{options[:subgrid][:sort_order]}',
                viewrecords: true,
                toolbar : [true,"top"], 
        		    #{subgrid_inline_edit}
        		    #{subgrid_direct_link}
        		    height: '100%'
        		})
        		.navGrid("#"+pager_id,{edit:#{options[:subgrid][:edit]},add:#{options[:subgrid][:add]},del:#{options[:subgrid][:delete]},search:false})
        		.navButtonAdd("#"+pager_id,{caption:"Search",title:"Toggle Search",buttonimg:'/images/jqgrid/search.png',
            	onClickButton:function(){ 
            		if(jQuery("#t_"+subgrid_table_id).css("display")=="none") {
            			jQuery("#t_"+subgrid_table_id).css("display","");
            		} else {
            			jQuery("#t_"+subgrid_table_id).css("display","none");
            		}
            	} 
            });
            jQuery("#t_"+subgrid_table_id).height(25).hide().filterGrid(""+subgrid_table_id,{gridModel:true,gridToolbar:true});
        	},
        	subGridRowColapsed: function(subgrid_id, row_id) {
        	},
        )
      end


      
      # Add options[:custom_buttons] to add custom buttons to nav bar.  Very useful for restful urls among other things.
      # It takes the following hash of arguments (or an array of hashes for many buttons):
      # :function_name => jsFunctionToCallWithSelectedIds, :caption => "Button", :title => "Press Me", :icon => "ui-icon-alert"
      custom_buttons = ""
      if options[:custom_buttons]
        options[:custom_buttons] = [options[:custom_buttons]] unless options[:custom_buttons].kind_of?(Array)
        get_ids_call = options[:multi_selection] ?  'selarrrow' : 'selrow'
        options[:custom_buttons].find_all{|custom_button_details|  custom_button_details.kind_of?(Hash) }.each do |button_properties_hash|
          next if button_properties_hash[:function_name].blank?
          button_properties_hash[:id_not_required] ||= false
          custom_buttons += %Q^.navButtonAdd(
            '##{id}_pager',
            {
              caption:"#{escape_javascript(button_properties_hash[:caption]) || ''}",
              title:"#{escape_javascript(button_properties_hash[:title]) || 'Custom Button'}", 
              buttonicon:"#{button_properties_hash[:icon] || "ui-icon-alert"}",^ 
          if button_properties_hash[:id_not_required]
            custom_buttons += %Q^    
                onClickButton: function(){ 
                                #{button_properties_hash[:function_name]}();
                              }
              })
            ^
          else
            custom_buttons += %Q^    
                onClickButton: function(){ 
                                var selected_ids = jQuery("##{id}").getGridParam("#{get_ids_call}")
                                #{ 
                                #no check for null selected_ids as someone may want an Add button or something similar
                                }
                                #{button_properties_hash[:function_name]}(selected_ids);
                              }
              })
            ^
          end  
        end
      end
      
      # Generate required Javascript & html to create the jqgrid
      %Q(
    <!--  <link rel="stylesheet" type="text/css" media="screen" href="/stylesheets/jqgrid/ui.jqgrid.css" /> -->
        <script type="text/javascript">
          var lastsel;
          #{'jQuery(document).ready(function(){' unless options[:omit_ready]=='true'}
          var mygrid#{id.camelcase} = jQuery("##{id}").jqGrid({
              url:'#{action}?q=1',
              editurl:'#{options[:edit_url]}',
              datatype: "json",
              colNames:#{col_names},
              colModel:#{col_model},
              pager: '##{id}_pager',
              rowNum:#{options[:rows_per_page]},
              rowList:[10,25,50,100],
              imgpath: '/images/jqgrid',
              sortname: '#{options[:sort_column]}',
              viewrecords: true,
              sortorder: '#{options[:sort_order]}',
              gridview: #{options[:gridview]},
              scrollrows: true,
              autowidth: #{options[:autowidth]},
              rownumbers: #{options[:rownumbers]},
              topinfo: '#{options[:topinfo]}',
              #{options[:height].blank? ? '' : "height:" + "'" + options[:height].to_s + "'" + ',' }
              #{options[:width].blank? ? '' : "width:" + "'" + options[:width].to_s + "'" + ',' }
              #{post_data} 
              #{multiselect}
              #{masterdetails}
              #{grid_loaded}
							#{other_events}
              #{direct_link}
              #{double_click}
              #{editable}
              #{subgrid_enabled}
              #{subgrid}
              caption: "#{title}"
            })
            .navGrid('##{id}_pager',
              {edit:#{edit_button},add:#{options[:add]},del:#{options[:delete]},search:false,refresh:true},
              {afterSubmit:function(r,data){return #{options[:error_handler_return_value]}(r,data,'edit');}},
              {afterSubmit:function(r,data){return #{options[:error_handler_return_value]}(r,data,'add');}},
              {afterSubmit:function(r,data){return #{options[:error_handler_return_value]}(r,data,'delete');}}
            )
            #{custom_buttons}
            #{search}
            #{multihandler}
            #{selection_link}
            #{filter_toolbar}
          #{'})' unless options[:omit_ready]=='true'};
        </script>
        <table id="#{id}" class="scroll" cellpadding="0" cellspacing="0"></table>
        <div id="#{id}_pager" class="scroll" style="text-align:center;"></div>
      )
    end

    private
    include JqgridUtilities

end # End Jqgrid module

module JqgridJson
  include JqgridUtilities
  def to_jqgrid_json(attributes, current_page, per_page, total, options={})
    json = %Q({"page":"#{current_page}","total":#{total/per_page.to_i+1},"records":"#{total}")
    if total > 0
      json << %Q(,"rows":[)
      each do |elem|
        elem.id ||= index(elem)
        json << %Q({"id":"#{elem.id}","cell":[)
        couples = elem.attributes.symbolize_keys
        attributes.each do |atr|
          value = get_atr_value(elem, atr, couples, options)
          value = escape_javascript(value) if (value and value.is_a?(String))
          json << %Q("#{value}",)
        end
        json.chop! << "]},"
      end
      json.chop! << "]}"
    else
      json << "}"
    end
  end

  private
  
  def get_atr_value(elem, atr, couples, options={})
    if atr.instance_of?(String) && atr.to_s.include?('.')
      value = get_nested_atr_value(elem, atr.to_s.split('.').reverse) 
    else
      value = couples[atr]
			value = _resolve_value(atr, elem)
    end
    value = (value ? options[:true_text] || "Yes" : options[:false_text] || "No") if value.instance_of?(TrueClass) || value.instance_of?(FalseClass)
    value = '' if atr == :blank_field
    value
  end

	def _resolve_value value, record
	  case value
	  when Symbol
	    if record.respond_to?(value)
	      record.send(value) 
	    else 
	      value.to_s
	    end
	  when Proc
	    value.call(record)
	  else
	    value
	  end
	end
  
  def get_nested_atr_value(elem, hierarchy)
    return nil if hierarchy.size == 0
    atr = hierarchy.pop
    raise ArgumentError, "#{atr} doesn't exist on #{elem.inspect}" unless elem.respond_to?(atr)
    nested_elem = elem.send(atr)
    return "" if nested_elem.nil?
    value = get_nested_atr_value(nested_elem, hierarchy)
    value.nil? ? nested_elem : value
  end
end # End JqgridJson module

module ApplicationHelper
  def jqgrid_restful_add_edit_delete_buttons(options={})
    options[:width] ||= 600

    events = ","
    events << %Q(onInitializeForm: #{options[:on_initialize_form] + ","}) unless options[:on_initialize_form].blank?
    events << %Q(beforeShowForm: #{options[:before_show_form] + ","}) unless options[:before_show_form].blank?
    events << %Q(editData: #{get_sub_options(options[:edit_data]) + ","}) unless options[:edit_data].blank?
    events.chomp!(",")

    options[:add_function] ||= %Q(
		jQuery("##{options[:div_object]}").editGridRow("new",
			{	mtype:'POST',
				closeAfterAdd:true,
				width:#{options[:width]},
				reloadAfterSubmit:true,
				afterSubmit:checkForAndDisplayErrors,
				url:'#{ options[:base_path] }' + '.json?' + (window.rails_authenticity_token ? '&authenticity_token='+encodeURIComponent(window.rails_authenticity_token) : '')
				#{events}
			}
			);
    )

    options[:edit_function] ||= %Q(
   	 	jQuery("##{options[:div_object]}").editGridRow(id,
   	 		{	mtype:'PUT',
   	 			closeAfterEdit:true,
   	 			width:#{options[:width]},
   				afterSubmit:checkForAndDisplayErrors,
   	 			reloadAfterSubmit:true,
   	 			url:'#{ options[:base_path] }/' + id + '.json?' + (window.rails_authenticity_token ? '&authenticity_token='+encodeURIComponent(window.rails_authenticity_token) : '')
  				#{events}
   			}
   			);
    )
    options[:delete_function] ||= %Q(
      jQuery("##{options[:div_object]}").delGridRow(id,
    		{	mtype:'DELETE',
    			closeAfterEdit:true,
    			reloadAfterSubmit:true,
    			afterSubmit:checkForAndDisplayErrors,
    			url:'#{ options[:base_path] }/' + id + '.json?' + (window.rails_authenticity_token ? '&authenticity_token='+encodeURIComponent(window.rails_authenticity_token) : '')
    		});
  		)

    options[:copy_function] ||= %Q(
   	 	jQuery("##{options[:div_object]}").delGridRow(id,
   	 		{	mtype:'POST',
   	 			closeAfterEdit:true,
   	 			width:#{options[:width]},
   				afterSubmit:checkForAndDisplayErrors,
   	 			reloadAfterSubmit:true,
          caption: "Copy",
          msg: "Copy selected #{options[:name].singularize.camelcase}?",
          bSubmit: "Copy",
          bCancel: "Cancel",
   	 			url:'#{ options[:base_path] }/' + id + '/copy.json?' + (window.rails_authenticity_token ? '&authenticity_token='+encodeURIComponent(window.rails_authenticity_token) : '')
  				#{events}
   			}
   			);
    )

  	options[:get_page_for_selected_id] ||= %Q('#{options[:base_path]}')

    return "" if options[:name].blank? || options[:base_path].blank? || options[:div_object].blank?
    %Q(
      <script type="text/javascript">
      	function add#{options[:name].singularize.camelcase}() {
      	  #{options[:add_function]}
      	};
      	function edit#{options[:name].singularize.camelcase}(id){
      	 if( id != null )
           #{options[:edit_function]}
      	 else
      	 	alert("Please select a #{options[:name].singularize.downcase} to edit.");
      	 };

      	function delete#{options[:name].singularize.camelcase}(id){
      		if ( id != null )
            #{options[:delete_function]}
      		else
      			alert("Please select a #{options[:name].singularize.downcase} to delete");
      		}
    		function copy#{options[:name].singularize.camelcase}(id){
      		if ( id != null )
            #{options[:copy_function]}
      		else
      			alert("Please select a #{options[:name].singularize.downcase} to copy");
      		}	
      	function getPage(id){
      	  if ( id != null )
            document.location=#{ options[:get_page_for_selected_id] };
      		else
      			alert("Please select a #{options[:name].singularize.downcase}");
      		}

      </script>
    )
  end

  private

  include JqgridUtilities
end


module JqgridNotifiable
  def jqgrid_error_messages_for(activerecord_object)
    error_text = ""
     if activerecord_object
       activerecord_object.errors.entries.each do |error|
         if error[1] =~ /^!!\^/
           error_text << "<strong>#{error[1].gsub(/^!!\^/,'')}</strong><br/>"
         else
           error_text << "<strong>#{error[0]}</strong> : #{error[1]}<br/>"
         end
       end
     end
    render :json => [false,"#{error_text}"]
  end
end
