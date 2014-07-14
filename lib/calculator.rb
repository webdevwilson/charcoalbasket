require 'configuration'

class Calculator

  def self.calculate(spec)
    
    shape, dimensions = spec.scan( /^(round|square):([0-9x]+)$/ ).flatten
    
    if shape.eql? 'round'
      width, height = dimensions.scan(/^([0-9]+)x([0-9]+)$/).flatten.collect { |it| it.to_i }
      material = ((width / 2) * Math::PI) + ( width * Math::PI * height)
      is_custom = true
      dimensions = { :diameter => width, :height => height }
    else
      x, y, height = dimensions.scan(/^([0-9]+)x([0-9]+)x([0-9]+)$/).flatten.collect { |it| it.to_i }
      width = x > y ? x : y
      material = (x * y) + (2 * x * height) + (2 * y * height)
      dimensions = { :x => x, :y => y, :height => height }
      is_custom = ( x != 12 || y != 12 || height != 6 )
    end
    
    if width > 12 or height > 12
      shipping = 18
    else
      shipping = 15
    end
    
    { :shape => shape, :stainless => calculate_material(material, 'stainless', is_custom),
      :carbon => calculate_material(material, 'carbon', is_custom), :dimensions => dimensions, 
      :package_width => width + 2, :package_height => height + 2, :shipping => shipping }
    
  end
  
  def self.shipping(spec)
    
  end
  
  def self.calculate_material(material, type, is_custom)
    
    sheet_size = 48 * 96
    pricing = Configuration['pricing']
    
    # price = ( material * amt of material + labor ) x markup (rounded up and less a cent)
    material_cost = material * ( pricing['material'][type].to_f / sheet_size )
    price = (( material_cost + pricing['labor'][type]) * pricing['markup']).ceil - 0.01

    # add custom charge
    if(is_custom)
      price += Configuration['pricing']['custom']
    end
    
    # calculate weight, adjusting floating point to 2 decimals
    weight = material * ( Configuration['weight'][type] / sheet_size )
    weight = (weight * 100).round.to_f / 100
    
    { :price => price, :weight => weight }
    
  end
  
end