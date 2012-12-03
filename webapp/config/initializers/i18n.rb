# Fix a buggy I18n interpolation
# Can be removed after Rails 2.3.8
I18n::Backend::Simple::DEPRECATED_INTERPOLATORS["%d"] = "%d"
