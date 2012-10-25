document.observe('trisano:dom:loaded', function() {
  Trisano.Layout.initiaizeMainMenu();
  Trisano.Layout.hookWindowResize();
  Trisano.Layout.setMainContentPosition();  //Must go last!!
});

Trisano.Layout = {

  hookWindowResize: function() {
    $j(window).resize(function() {
      Trisano.Layout.setMainContentPosition();
    });  
  },

  toggleLogoMenu:function() {
    $j("div#head div.container div.right div.user").toggle();
    $j("#title_area").toggle();
    Trisano.Layout.setMainContentPosition();
  },

  hookLogoMenu: function() {
    $j("#logo-container").on('click', function() {
      Trisano.Layout.toggleLogoMenu();
      return false;
    });
  },

  setMainContentPosition: function () {
      var head_height = $j("#head").height()+ 5 + 'px';
      $j("#main-content").css('top', head_height);
  },

  initiaizeMainMenu: function() {
  }
};
