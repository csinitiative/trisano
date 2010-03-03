var I18n = Class.create({
  initialize: function(locale, translations) {
    this.locale = locale;
    this.translations = $H(translations);
  },

  t: function(key, interpolations) {
    if (typeof interpolations == 'undefined') {
      interpolations = {};
    }
    var value = this.translations.get(key);
    if (typeof value == 'undefined') {
      return '';
    } else {
      var template = new Template(value);
      return template.evaluate(interpolations);
    }
  }
});