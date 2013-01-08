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
Module.class_eval do

  # Plugins can use this to monkey patch core classes in a way that
  # won't fail after reload. Helpful when developing plugins
  def hook!(other_mod_name)
    ActionController::Dispatcher.to_prepare(self.to_s + other_mod_name.to_s) do
      this_mod  = eval self.to_s
      other_mod = eval other_mod_name.to_s
      unless other_mod.included_modules.include? this_mod
        other_mod.send :include, this_mod
      end
    end
  end

  # marks a class unloadable (and thus reloadable), attentive to
  # config.cache_classes. Useful in plugins, for which class reloading
  # is hit or miss.
  def reloadable!
    self.unloadable if ActiveSupport::Dependencies.load?
  end
end
