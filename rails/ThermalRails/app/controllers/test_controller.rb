class TestController < ApplicationController
  def index
  	@json_vars = {"test1" => 3, "test2" => "boom"}
  	@params = params
  	respond_to do |format|
	  format.json do
	    render :json => @json_vars
	  end
	  format.html
	  
    end
  end
end
