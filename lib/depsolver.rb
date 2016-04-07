
module Depsolver
require 'json'

  def load_recipes(recipes)

    recipe_files = Dir['lib/recipes/*.json']
    recipe_files.each do |file_name|
      file_contents = File.open(file_name, 'r').read
      recipes.merge!(JSON.parse(file_contents))
    end  

    recipes.each do |recipe|
      recipes[recipe[0]]['result_count'] = 1 unless recipe[1].key?('result_count')
    end
    return recipes
  end  

  def find_deps(product, recipes)
    product.each do |item, amount|
      recipes[item]['ingredients'].each do |ingredient, ingredient_amount|
        amount_needed = (ingredient_amount * amount) / recipes[item]['result_count']

        if @final_ingredients[ingredient].nil?
          @final_ingredients[ingredient] = amount_needed
        else
          @final_ingredients[ingredient] = amount_needed + @final_ingredients[ingredient]
        end

        unless recipes[ingredient].nil?
          find_deps({ ingredient => amount_needed }, recipes)
        end
      end
    end
    return @final_ingredients
  end

  def set_fuel_source(recipes, solid_fuel)

  #solid_fuel source
    if solid_fuel.eql? "petroleum-gas"
      recipes['solid-fuel'] = recipes['solid-fuel-from-petroleum-gas']
    elsif solid_fuel.eql? "heavy-oil"
      recipes['solid-fuel'] = recipes['solid-fuel-from-heavy-oil']
    else
      recipes['solid-fuel'] = recipes['solid-fuel-from-light-oil']
    end
    return recipes

  end

  def depsolver(final_product, solid_fuel="light-oil")
    @final_ingredients = {}

    # final win condition
  #  final_product = {
  #    'rocket-silo' => 1,
  #    'rocket-part' => 100,
  #    'satellite' => 1
  #  }
    recipes = {}
    recipes = load_recipes(recipes)
    puts solid_fuel
    recipes = set_fuel_source(recipes, solid_fuel)
    puts recipes["solid-fuel"]
    final_result = find_deps(final_product, recipes)

#    final_result.keys.sort.each do |item|
#      puts "#{item}: #{final_result[item]}"
#    end
    return final_result
  end

end