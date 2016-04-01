#!/usr/bin/env ruby

require 'json'

def load_recipes
  recipes = {}

  recipe_files = Dir['recipes/*.json']
  recipe_files.each do |file_name|
    file_contents = File.open(file_name, 'r').read
    recipes.merge!(JSON.parse(file_contents))
  end

  recipes.each do |recipe|
    recipes[recipe[0]]['result_count'] = 1 unless recipe[1].key?('result_count')
  end
  recipes
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
  @final_ingredients
end

@final_ingredients = {}

# final win condition
final_product = {
  'rocket-silo' => 1,
  'rocket-part' => 100,
  'satellite' => 1
}

recipes = load_recipes
final_result = find_deps(final_product, recipes)

final_result.keys.sort.each do |item|
  puts "#{item}: #{final_result[item]}"
end

exit
