document.observe('trisano:dom:loaded', function() {
  Trisano.Layout.initiaizeMainMenu();
  Trisano.Layout.hookWindowResize();
  Trisano.Layout.initFormChangePopup();
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
  },

  initFormChangePopup: function() {
    $j("#form-references-dialog").dialog({title:"Update event forms", width:700});

    $j("#cancel_forms_button").click(function(event){
      $j("#form-references-dialog").dialog('close');
      event.stopPropagation();
      event.preventDefault();
    });

    $j("#form-references-dialog input[type=checkbox]").click(function(){
      var has_changed_forms = $j("#form-references-dialog input[type=checkbox]:checked").length > 0;
      if (has_changed_forms) {
        $j("#save_forms_button").removeAttr("disabled");
      } else {
        $j("#save_forms_button").attr("disabled", "disabled");
      }
    });

    $j("#save_forms_button").click(function(event){
      if (!window.confirm("Are you sure you want to remove the forms? Removing a form will also remove all answers to questions on that form.")) {
        event.stopPropagation();
        event.preventDefault();
      }
    });
  },

  clearFlashMessage: function() {
    $j("#flash-message").html();
  },

  setFlashMessage: function(message) {
    $j("#flash-message").html(message);
    Trisano.Layout.setMainContentPosition();
  },

  setFlashMessageClass: function(class_name) {
    $j("#flash-message").attr('class', class_name);

  },

  navToFlashMessage: function() {
    var position = $j('#flash-message').offset().top - $j("#head").height();
    $j(window).scrollTop(position);    
  }
};
