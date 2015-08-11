class HomeController < ApplicationController
  before_action :set_teams

  def index
  end

  def teams
    respond_to do |format|
      format.css
    end
  end

  protected
    def set_teams
      @teams = Team.all
    end
end
