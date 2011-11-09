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
            var qty=qi.intVal(1);
            
            // is stainless option checked?
            var stainless = si[0].checked;
            var soc=stainless ? 'stainless' : 'carbon';
            var stainlessPrice = ((data['stainless'].price - data['carbon'].price) * qty).toFixed(2);
            var subtotal = (data[soc].price * qty).toFixed(2);
			$('#item_width, #item_length').val(data.width);
			$('#item_height').val(data.height);
            $('#subtotal').text(subtotal);
            $('#stainless_option_price').text(stainlessPrice);
            $('input[name="item_price"]').val(subtotal);
            $('#item_weight').val(data[soc].weight);
                
        }
        
        si.change(recalculate);
        qi.keyup(recalculate);
        
        // custom size fields
        (function setupCustomSizeForm() {
            
            var specChanged = function() {
              var s=$('#shape').val();
              if(s == 'round') {
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
        var select = function() { this.select(); };
        $('.selectOnFocus').mouseup(select);
        
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
        
        // show round or circular dimension fields
        (toggleFields = function() {
            $('div[id$="_fields"]').hide();
            $('div#' + $('#shape').val() + '_fields').show();
        })();
        $('select#shape').change(toggleFields);
        
        
    })();

});

$.fn.intVal = function() {
    var defVal=arguments[0] ? arguments[0] : 0;
    var v=parseInt(this.val());
    return isNaN(v) ? defVal : v;
}