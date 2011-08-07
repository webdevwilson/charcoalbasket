require 'configuration'

class Calculator

  def self.calculate(spec, type)
    
    shape, dimensions = spec.scan( /^(round|square):([0-9x]+)$/ ).flatten
    
    if shape.eql? 'round'
      width, height = dimensions.scan(/^([0-9]+)x([0-9]+)$/).flatten.collect { |it| it.to_i }
      material = ((width / 2) * Math::PI) + ( width * Math::PI * height)
    else
      x, y, height = dimensions.scan(/^([0-9]+)x([0-9]+)x([0-9]+)$/).flatten.collect { |it| it.to_i }
      width = x > y ? x : y
      material = (x * y) + (2 * x * height) + (2 * y * height)
    end

    type = type.to_s
    pricing = Configuration['pricing']
    sheet_size = 48 * 96
    
    # price = ( material * amt of material + labor ) x markup (rounded up and less a cent)
    material_cost = material * ( pricing['material'][type].to_f / sheet_size )
    price = (( material_cost + pricing['labor'][type]) * pricing['markup']).ceil - 0.01
    
    # add custom charge
    if( x != 12 || y != 12 || height != 6 )
      price += Configuration['pricing']['custom']
    end
    
    # calculate weight, adjusting floating point to 2 decimals
    weight = material * ( Configuration['weight'][type] / sheet_size )
    weight = (weight * 100).round.to_f / 100
    
    { :price => price, :weight => weight, :width => width, :height => height }
    
  end
    
end