class HomeController < ApplicationController
  before_action :set_teams, except: [ :stats ]
  before_action :set_rewards, only: [ :index ]

  def index
  end

  def teams
    respond_to do |format|
      format.json
      format.css
    end
  end

  def stats
    @data = Team.statistics

    respond_to do |format|
      format.json
    end
  end

  protected
    def set_teams
      @teams = Team.with_score
    end

    def set_rewards
      @rewards = Reward.order('created_at DESC').limit(10)
    end
end
