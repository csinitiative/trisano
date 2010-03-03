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
