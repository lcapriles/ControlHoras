/*
 * jqPersist - Extension to jqGrid to persist paramData in localStorage 
 * see: http://dev.w3.org/html5/webstorage/
 *
 * Copyright (c) 2010 Petrica Ghiurca <petrica@ghiurca.net>, http://petrica.ghiurca.net
 * Licensed under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
Storage.prototype.setObject = function(key, value) {
    this.setItem(key, JSON.stringify(value));
}

Storage.prototype.getObject = function(key) {
    return JSON.parse(this.getItem(key));
}

var persistGridState = function(postData) {
	if (localStorage) {
		var key = 'gridParams:' + window.location.pathname + ":" + this.id;
		if (!this.p.pageLoaded) {
			$('span.ui-jqgrid-title', $('#gbox_'+this.id)).append('<span class="filtering"></span>');

			if (localStorage.getItem(key)) {
				postData = localStorage.getObject(key);
				if (postData._search) {
					colModel = this.p.colModel
					filter = ""
					filters_count = 0;
					for (var col in colModel) {
						var colName = colModel[col].name;
						if (postData[colName]) {
							if (filters_count > 0) filter += " and ";
							filter += colName + ": " + postData[colName];
							filters_count++;
						}
					}
					$('span.ui-jqgrid-title span.filtering', $('#gbox_'+this.id)).append('<span class="state-indicator">Filtered on ' + filter + '</span>');
				}

				if (postData.sidx)
					$('span.ui-jqgrid-title span.filtering', $('#gbox_'+this.id)).append('<span class="state-indicator">Sorted on ' + postData.sidx + '</span>');

				if (postData.page > 1)
					$('span.ui-jqgrid-title  span.filtering', $('#gbox_'+this.id)).append('<span class="state-indicator">Page ' + postData.page + '</span>');

				var grid_id = this.id;
				$('#refresh_' + this.id).live('mouseup', function() {
					$('span.ui-jqgrid-title span.filtering', $('#gbox_'+grid_id)).empty();
				});
			}
			this.p.pageLoaded = true;
		} else {
			localStorage.setObject(key, postData);
		}
	}
  return postData;
}