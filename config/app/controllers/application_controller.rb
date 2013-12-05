class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :initialize_votes

  def initialize_votes
    if ! session[:votes]
      session[:votes] = Array.new
    end
  end

end
