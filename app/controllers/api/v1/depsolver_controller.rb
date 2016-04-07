class Api::V1::DepsolverController < ApplicationController
  include ActionController::MimeResponds
  include Depsolver

  def view

    incoming_message = request.body.read
    puts incoming_message
    message_body = JSON.parse(incoming_message)
    if message_body["solid_fuel_source"].nil?
      solid_fuel = "light-oil"
    else
      solid_fuel = message_body["solid_fuel_source"]
    end
    puts solid_fuel
    final_product = depsolver(message_body['final_product'],solid_fuel)



    respond_to do |format|
      msg = final_product

      format.json { render :json => msg}
      format.html { render :html => "HTML is not implemented"}
    end

  end
end