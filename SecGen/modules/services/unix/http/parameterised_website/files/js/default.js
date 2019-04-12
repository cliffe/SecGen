$( function() {
    $( "#tabs" ).tabs({
        beforeLoad: function( event, ui ) {
            ui.jqXHR.fail(function() {
                ui.panel.html(
                    "Couldn't load this tab. We'll try to fix this as soon as possible. " );
            });
        }
    });
} );