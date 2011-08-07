// add events
$(function() {

    // default dimension
    var height = 12;
    var width = 12;
    var depth = 6;
    var standardDim = 'square:12x12x6';
    var dim=standardDim;
    var mode = 0;

    var update = function(calc) {
        var product;
        if(mode == 1) {
            product = {

            };
            size = 'square:12x12x6';
            description = 'Charcoal Smoker Box';
        } else if(mode == 2) {
            size = $('#brand_selector').val();
            description = $('#brand_selector option:selected').text();
        } else if(mode ==3) {
            description = 'Custom Sized';
            if($('#shape').val()=='square'){
                size='square:'+$('#square_width').val()+'x'+$('#square_height').val()+'x'+$('#square_depth').val();
            }else{
                size='round:'+$('#round_radius').val()+'x'+$('#round_depth').val();
            }
        }

    }

    // choose size selected
    $('#standard-size').click(function() {
        $('#by_brand').hide();
        $('#custom_sizing').hide();
    }).click(update);

    // product radio selected
    $('#product-sizing').click(function() {
        mode = 2;
        update(function() {

        });
        $('#by_brand').show();
        $('#custom_sizing').hide();
    }).click(update);

    // custom sizing option
    $('#custom-sizing').click(function() {
        mode = 3;
        update(function() {

        });
        $('#by_brand').hide();
        $('#custom_sizing').show();
    }).click(update);

    $('#brand_selector').change(update);

    $('#shape').change(update).change( function() {
        if($(this).value() == 'Square') {
            $('#square_fields').show();
            $('#round_fields').hide();
        } else {
            $('#square_fields').hide();
            $('#round_fields').show();
        }
    });

    // update description box
    function updateDescription() {
        var shape = dim.substr(0,dim.indexOf(':'));
        var size = dim.substr(dim.indexOf(':')+1).split('x');
        var brand = '';
        var item = {};

        if( $('#product-sizing').attr('checked') ) {
            item.name = $('#brand_selector option:selected').text();
            item.desc = $('#brand_selector option:selected').text();
        } else {
            item.name = "Charcoal Smoker Box";
            if( $('#standard-size').attr('checked') ) {
                item.desc = '12" x 12" x 6" Depth';
            } else {
                if(shape=='square')
                    item.desc = brand+size[0]+'" x '+size[1]+'" x '+size[2]+'" Depth';
                else
                    item.desc = brand+size[0]+'" Diameter x '+size[1]+'" Depth';
            }
        }

        if( $('#finish_it').attr('checked') ) {
            item.desc += " Finished";
        } else {
            item.desc += " Unfinished";
        }
        $('#item_name').val(item.name);
        $('#item_description').val(item.desc);
    }

    // set current dimension
    function setDimensions(d) {
        dim = d;
        var shape = dim.substr(0,dim.indexOf(':'));
        var size = dim.substr(dim.indexOf(':')+1).split('x');
        if( shape == 'round' ) {

            var r=size[0];
            var d=size[1];

            // validate
            if(r<4||r>24){
                alert("Diameter is invalid.");
                return;
            }
            if(d<1||d>24){
                alert("Depth is invalid.");
                return;
            }

            // calculate material
            updatePrice(Math.round(((r*3.145*d)+(r*r))*.0185+25+37)-.01);

        } else if( shape == 'square' ) {

            var x=size[0];
            var y=size[1];
            var z=size[2];

            // validate
            if(x<4||y<4||z<4||x>24||y>24||z>24){
                alert("Dimensions invalid.");
                return;
            }

            // catch 'standard' sizes
            if(x==12&&y==12&&z==6)
                updatePrice(69.99);
            else
                updatePrice(Math.round(((x*y)+(y*z*2)+(x*z*2))*.0185+25+45)-.01);
        }
    }

    // update price fields
    function updatePrice(subtotal) {

        if( $('#finish_it').attr('checked') ) {
            subtotal += 5;
        }
        if( $('#custom-sizing').attr('checked') ) {
            subtotal += 15;
        }
        var price = subtotal;
        subtotal = subtotal * quantity();

        $('#amount').html(subtotal.toFixed(2));
        $('#subtotal').html((subtotal + 15).toFixed(2));

        $('#item_price').value(price);
    }

    // get quantity
    function quantity() {

        updateDescription();

        var quantity = parseInt($('#item_quantity').value());
        if( ! quantity > 0 ) {
            quantity = 1;
            $('#item_quantity').value(quantity);
        }
        return quantity;
    }

    function dimensionBlur() {
        customSize();
    }

    // convert custom fields to dimensional string
    function customSize() {
        var s = $('#shape option:selected').value();
        if(s=='Square'){
            setDimensions('square:'+$('#square_width').value()+'x'+$('#square_height').value()+'x'+$('#square_depth').value());
        }else{
            setDimensions('round:'+$('#round_radius').value()+'x'+$('#round_depth').value());
        }
    }
});