# We raise our own exceptions to fool rails
module Trisano
  class MissingTranslation < I18n::ArgumentError; end
end

# fail as soon as we miss a translation
I18n.instance_eval do
  alias :translate_quiet :translate
  def translate(key, options = {})
    options = options.merge(:raise => true)
    translate_quiet(key, options)
  rescue I18n::MissingTranslationData => te
    raise(Trisano::MissingTranslation, te.message)
  end
  alias :t :translate
end
