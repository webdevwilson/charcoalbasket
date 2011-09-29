$(function() {

    (function setupLayoutDefaults() {
        $('a[href^="/images"]').lightBox( {
            'baseUrl': '/js/jquery.lightbox-0.5/'
        });
        $('#navigation li').click(function() {
            window.location = $(this).find('a').attr('href');
            return false;
        });
    })();
    

    (function setupPurchasePage() {
        $('a[id^="explain"]').click(function() {
            var n=$('#why_' + $(this).attr('id').substring(8));
            if(n.attr('state') != 'open') {
                n.fadeIn().attr('state','open');
            } else {
                n.fadeOut().attr('state','closed');
            }
            return false; 
        });
   
        $('a[id^="close"]').click(function() {
            $('#why_' + $(this).attr('id').substring(6)).fadeOut();
            return false; 
        });
    })();

});