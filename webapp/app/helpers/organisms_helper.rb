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
module OrganismsHelper

  def organism_tools(organism)
    haml_tag :div, :class => 'tools' do
      haml_concat link_to_unless_current(t('show'), organism)
      haml_concat "&nbsp;|&nbsp;"
      haml_concat link_to_unless_current(t('edit'), edit_organism_path(organism))
    end
  end

  def diseases_organism_options
    Disease.all(:order => 'disease_name').collect do |d|
      [d.disease_name, d.id]
    end
  end
end
