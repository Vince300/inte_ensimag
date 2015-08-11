class HomeController < ApplicationController
  before_action :set_teams
  before_action :set_rewards, only: [ :index ]

  def index
  end

  def teams
    respond_to do |format|
      format.css
    end
  end

  protected
    def set_teams
      # Note that we can use greedy requests, there are only 4 teams
      @teams = Team.all.to_a.sort_by { |team| -team.current_score }
    end

    def set_rewards
      @rewards = Reward.order('created_at DESC').limit(20)
    end
end
