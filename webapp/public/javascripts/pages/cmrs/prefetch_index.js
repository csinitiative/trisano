Trisano.CmrsPrefetchIndex = {

    init : function() {
        return;

        this.prefetchIndex();
    },

    /**
     * Prefetch the edit page to ensure it is in the cache
     */
    prefetchIndex : function() {
        $j("a.edit_link, a.show_link").each(function(i) {
           $j.ajax({
              url: this,
              success: function() {
                // Do nothing
              }
            });
        });
    }

};

$j(document).ready(function() {
    Trisano.CmrsPrefetchIndex.init();
});