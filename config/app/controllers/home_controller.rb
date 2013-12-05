class HomeController < ApplicationController

  def index
    if (params[:party_identifier])
      party = Party.find_by_identifier(params[:party_identifier])
      if party
        redirect_to party
      else
        flash[:error] = "Whoops! That party doesn't exist!"
        redirect_to :back
      end
    end
  end
end
