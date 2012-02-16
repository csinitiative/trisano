Trisano.CmrsPrefetchEdit = {

    init : function() {
        this.prefetchEdit();
    },

    /**
     * Prefetch the edit page to ensure it is in the cache
     */
    prefetchEdit : function() {
        var url = window.location.pathname + "/edit";

        $j.ajax({
          url: url,
          complete: function() {
            // Do nothing
          }
        });
    }

};

$j(document).ready(function() {
    Trisano.CmrsPrefetchEdit.init();
});