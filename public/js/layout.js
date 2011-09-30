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
        
        var specCache = {};
        
        // calculates and redisplays price info
        var qi = $('input#item_quantity');
        var si = $('input#stainless_option');
        var recalculate = function() {
            
            // call server to get spec information
            var spec = $('input#spec').val();
            if(!specCache[spec]) {
                $.getJSON('/calculate.json', {
                    's': spec
                }, function(d) {specCache[spec] = d;updateUI(d);});    
            } else {
                updateUI(specCache[spec]);
            }
        };
        
        var updateUI = function(data) {
            
            // get quantity, default to 1
            var qty=parseInt(qi.val());
            qty = qty > 1 ? qty : 1;
                
            // is stainless option checked?
            var stainless = si[0].checked;
            
            var subtotal = (data[ stainless ? 'stainless' : 'carbon' ].price * qty).toFixed(2);
            $('#subtotal').text(subtotal);
            $('input[name="item_price"]').val(subtotal)
                
        }
        
        si.change(recalculate);
        qi.keyup(recalculate).mouseup(function() {this.select()});
        
        (function infoBoxes() {
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
        
    })();

});