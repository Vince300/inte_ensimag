class HomeController < ApplicationController
  before_action :set_teams, except: [ :stats ]
  before_action :set_rewards, only: [ :index ]

  # GET /
  def index
  end

  # GET /teams.json
  #     /teams.css
  def teams
    respond_to do |format|
      format.json
      format.css
    end
  end

  # GET /stats.json
  def stats
    @data = Team.statistics

    respond_to do |format|
      format.json
    end
  end

  # GET /admin
  def admin
  end

  # POST /points?team=:team
  def points
    begin
      points = params[:points].to_i
      subject = if params[:subject].blank? or params[:subject] =~ /^\s+$/
                  nil
                else
                  params[:subject]
                end
      teams = Team.find params[:team]

      raise "Vous devez indiquer le nombre de points" if points <= 0

      teams.each do |team|
        team.rewards.create(amount: points,
                            subject: subject)
      end

      redirect_to admin_path, notice: "#{t('inte.points_phrase', count: points)} accordés aux #{teams.map { |t| t.name }.join(', ')} (occasion : #{subject})"
    rescue Exception => e
      if e.kind_of? ActiveRecord::RecordNotFound
        redirect_to admin_path, flash: { error: "Vous devez sélectionner au moins une équipe." }
      else
        redirect_to admin_path, flash: { error: e.to_s }
      end
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