/*
# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
*/
$j(function() {
  $j('.apply_to_diseases').click(function() {
    var buttons = {};
    buttons[i18n.t('select_all')] = function() {
      $j('#dialog_disease_list input:checkbox').attr('checked', true);
    };
    buttons[i18n.t('update')] = function() {
      $j('#diseaseListSpinner').show();
      $j('#apply_to_disease_form').submit();
    };

    $j('.apply_to_disease_dialog').dialog({
      title: i18n.t('apply_to_diseases'),
      height: 300,
      width: 600,
      open: function(event, ui) {
        $j('#dialog_disease_list').empty();
        $j('#diseaseListSpinner').show();
        var diseasesUrl = $j('.apply_to_disease_dialog a').attr('href');
        $j.getJSON(diseasesUrl, function(data, textStatus) {
          $j('#diseaseListSpinner').hide();
          $j('#diseaseListTemplate').tmpl(data).appendTo('#dialog_disease_list');
        });
      },
      buttons: buttons
    });
  });

});
