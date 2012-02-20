Trisano.CmrsModifiedTabs = {

    initialTabHtml : {},

    initialHasFollowupElements : {},

    init : function() {
        var self = this;

        $j("div.tab").each(function(t) {
            var tab_key = '';
            var tab_id = $j(this).attr('id');

            $j(this).find('*').each(function(c) {
                var value = $j(this).val();
                var name = $j(this).attr('name');
                var id = $j(this).attr('id');
                tab_key += value;

                if (self.hasFollowupElement(name)) {
                    self.initialHasFollowupElements[name] = value;
                }
                else if (name == "morbidity_event[disease_event_attributes][disease_id]") {
                    self.initialHasFollowupElements[name] = value;
                }

            });

            $j(this).find(':checked').each(function() {
                tab_key += $j(this).attr('name') + '1';
            });

            self.initialTabHtml[tab_id] = tab_key;
        });

        this.prefetchShow();
    },


    /**
     * Prefetch the show page to ensure it is in the cache
     */
    prefetchShow : function() {
        var url = window.location.pathname;
        url = url.replace(/\/edit/, '');

        $j.ajax({
          url: url,
          complete: function() {
            // Do nothing
          }
        });
    },

    setChangedTabs : function() {
        var self = this;

        $j("div.tab").each(function(t) {
            var id = $j(this).attr('id');
            var initial = self.initialTabHtml[id];
            var current = '';

            $j(this).find('*').each(function(c) {
                var name = $j(this).attr('name');
                var value = $j(this).val();
                current += value;
                if (self.initialHasFollowupElements[name] != undefined && self.initialHasFollowupElements[name] != value) {
                    self.expireAll();
                }
            });

            $j(this).find(':checked').each(function() {
                current += $j(this).attr('name') + '1';
            });

            if (current != initial) {
                self.expireTab(id);
            }
        });
    },

    expireTab : function(id) {
        var form = $j(".edit_morbidity_event").first();
        $j('<input>').attr({
            type: 'hidden',
            name: 'expire_cache[' + id + ']',
            value: true
        }).appendTo(form);
    },

    hasFollowupElement : function(name) {
        return (Trisano.FollowupCorePaths[name]) ? true : false;
    },

    expireAll : function() {
        var form = $j(".edit_morbidity_event").first();
        $j('<input>').attr({
            type: 'hidden',
            name: 'expire_cache_all',
            value: true
        }).appendTo(form);
    }

};


$j(document).ready(function() {
    Trisano.CmrsModifiedTabs.init();
});