var I18n = Class.create({
  locale: null,
  translations: null,

  initialize: function(locale, translations) {
    I18n.locale = locale;
    I18n.translations = $H(translations);
  },

  t: function(key, interpolations) {
    if (typeof interpolations == 'undefined') {
      interpolations = {};
    }
    var value = I18n.translations.get(key);
    if (typeof value == 'undefined') {
      return '';
    } else {
      var template = new Template(value);
      return template.evaluate(interpolations);
    }
  }
});
