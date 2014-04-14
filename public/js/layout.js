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
    
    if( $('#BB_BuyButtonForm').length === 1 ) {
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
                    }, function(d) {
                        specCache[spec] = d;
                        updateUI(d);
                    });    
                } else {
                    updateUI(specCache[spec]);
                }
            };
        
            var updateUI = function(data) {
            
                // get quantity, default to 1
                var qty=qi.intVal(1);
            
                // is stainless option checked?
                var stainless = si[0].checked;
                var soc=stainless ? 'stainless' : 'carbon';
                var stainlessPrice = ((data['stainless'].price - data['carbon'].price) * qty).toFixed(2);
                var subtotal = (data[soc].price * qty).toFixed(2);
                $('#item_width, #item_length').val(data.package_width);
                $('#item_height').val(data.package_height);
                $('#subtotal').text(subtotal);
                $('#stainless_option_price').text(stainlessPrice);
                $('#item_price').val(data[soc].price);
                $('#item_weight').val(data[soc].weight);
                
                // update description
                var text,
                dim = data.dimensions;
                x = "\" x ";
                if(data.shape === 'square') text = dim.x + x + dim.y + x + dim.height + "\" Depth";
                else text = dim.diameter + x + dim.height + "\" Depth";
                text = $('#item_name').val() + ' ' + text;
                
                if(stainless) text = "Stainless " + text;
                $('#item_description').val(text);
            };
        
            si.change(recalculate);
            qi.keyup(recalculate);
        
            // custom size fields
            (function setupCustomSizeForm() {
            
                var specChanged = function() {
                    var s=$('#shape').val();
                    if(s === 'round') {
                        $('#spec').val('round:'+$('#round_diameter').intVal(18)+'x'+$('#round_depth').intVal(6));
                    } else {
                        $('#spec').val('square:'+$('#square_x').intVal(12)+'x'+$('#square_y').intVal(12)+'x'+$('#square_z').intVal(6));
                    }
                    recalculate();
                };
            
                $('input.customSizeField').keyup(specChanged);
                $('select.customSizeField').change(specChanged);
         
            })();
        
            // do select on focus fields
            var select = function() {
                this.select();
            };
            $('.selectOnFocus').mouseup(select);
        
            (function infoBoxes() {
                $('a[id^="explain"]').click(function() {
                    var n=$('#why_' + $(this).attr('id').substring(8));
                    if(n.attr('state') !== 'open') {
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
        
            // show round or circular dimension fields
            (toggleFields = function() {
                $('div[id$="_fields"]').hide();
                $('div#' + $('#shape').val() + '_fields').show();
            })();
            $('select#shape').change(toggleFields);
        
            // call recalculate on page load, and form submission
            $(recalculate);
            $('#BB_BuyButtonForm').submit(recalculate);
            
            $('input[type=image][name=submit]').click(function() {
                var oid = new Date().getTime();
                var store = 'charcoalbasket.com';
                var total = $('#item_price').val();
                var tax = 0;
                var shipping = $('select[name=shipping]').val();
                var city = '';
                var state = '';
                var country = '';
                pageTracker._addTrans(oid, store, total, tax, shipping, city, state, country);
                
                var sku = $('#item_name').val();
                var name = $('#item_description').val();
                var category = 'Basket';
                var price = '';
                var qty = $('#item_quantity').val();
                pageTracker._addItem(oid, sku, name, category, price, qty);
                pageTracker._trackTrans();
            });
        
        })();
    }

});

$.fn.intVal = function() {
    var defVal=arguments[0] ? arguments[0] : 0;
    var v=parseInt(this.val());
    return isNaN(v) ? defVal : v;
};