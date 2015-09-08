class Team < ActiveRecord::Base
  # Use lowercase team name as parameter
  def to_param
    name.parameterize
  end

  # Scope to calculate scores along with loading team
  scope :with_score, -> {
    select(:id, :name, :color, 'COALESCE(current_score, 0) AS current_score', 'RANK() OVER (ORDER BY COALESCE(current_score, 0) DESC) AS rank', :created_at, :updated_at)
      .joins('LEFT OUTER JOIN (SELECT rewards.team_id, SUM(rewards.amount) AS current_score FROM rewards GROUP BY rewards.team_id) r ON r.team_id = "teams"."id"')
      .order('current_score DESC')
  }

  # Compute series data for charting
  def self.statistics
    sql = <<SQL
SELECT
  a.team_name, a.team_color, a.day,
  SUM(a.day_sum)
  OVER (PARTITION BY a.team_name
    ORDER BY a.day
    RANGE UNBOUNDED PRECEDING) AS total_sum
FROM (
       SELECT
         r.team_name,
         r.team_color,
         r.day,
         SUM(r.amount) AS day_sum
       FROM (
              SELECT
                teams.name                            AS team_name,
                teams.color                           AS team_color,
                date_trunc('day', rewards.created_at) AS day,
                COALESCE(rewards.amount, 0)           AS amount
              FROM teams
                LEFT OUTER JOIN rewards ON rewards.team_id = teams.id) r
       GROUP BY team_name, team_color, day) a ORDER BY day
SQL

    # Execute query and build data set
    result = {}
    min_date = nil
    self.connection.select_all(sql).each do |row|
      result[row['team_name']] = { data: [], team_color: row['team_color'] } unless result[row['team_name']]
      if row['day']
        d = row['day'].to_date
        min_date = d if min_date.nil? or min_date > d
        result[row['team_name']][:data] << [ d, row['total_sum'].to_i ]
      end
    end

    # Add last entry for today if necessary
    unless min_date.nil?
      today = [ Date.today, Date.parse('2015-09-29') ].min
      result.each do |k, v|
        if v[:data].length == 0 or v[:data][0][0] != min_date then
          # No points for this one yet
          v[:data].unshift [ min_date, 0 ]
        end

        unless v[:data][v[:data].length - 1][0] == today
          v[:data] << [ today, v[:data][v[:data].length - 1][1] ]
        end
      end
    end

    return result
  end

  # Event notification
  def self.notify_change
    connection.execute "NOTIFY teams, 'teams_changed'"
  end

  # Rewards relation
  has_many :rewards
end
