document.observe('trisano:dom:loaded', function() {
  Trisano.Layout.hookLogoMenu();
  Trisano.Layout.hookWindowResize();
  Trisano.Layout.setMainContentPosition();
});

Trisano.Layout = {

  hookWindowResize: function() {
    $j(window).resize(function() {
      Trisano.Layout.setMainContentPosition();
    });  
  },

  hookLogoMenu: function() {
    $j("#logo-container").on('click', function() {
      var options = {};
      $j("div#head div.container div.right div.user").toggle();
      $j("#title_area").toggle();
      $j("#bar").toggle();
      Trisano.Layout.setMainContentPosition();
      return false;
    });
  },

  setMainContentPosition: function () {
      var head_height = $j("#head").height() + 'px';
      $j("#main-content").css('top', head_height);
  }
};
