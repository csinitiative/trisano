Trisano.CmrsModifiedTabs = {

    initialTabHtml : {},

    init : function() {
        var self = this;

        $j("div.tab").each(function(t) {
            var id = $j(this).attr('id');
            var tab_key = '';
            $j(this).find('*').each(function(c) {
                tab_key += $j(this).val();
            });

            $j(this).find(':checked').each(function() {
                alert($j(this).attr('name') + '1');
                tab_key += $j(this).attr('name') + '1';

            });

            self.initialTabHtml[id] = tab_key;
        });
    },

    setChangedTabs : function() {
        var self = this;

        $j("div.tab").each(function(t) {
            var id = $j(this).attr('id');
            var initial = self.initialTabHtml[id];
            var current = '';

            $j(this).find('*').each(function(c) {
                current += $j(this).val();
            });

            $j(this).find(':checked').each(function() {
                alert($j(this).attr('name') + '1');
                current += $j(this).attr('name') + '1';
            });

            if (current != initial) {
                alert(id);
                var form = $j(".edit_morbidity_event").first();
                $j('<input>').attr({
                    type: 'hidden',
                    name: 'expire_cache[' + id + ']'
                }).appendTo(form);
            }
        });
    }

};


$j(document).ready(function() {
    Trisano.CmrsModifiedTabs.init();
});