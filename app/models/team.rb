class Team < ActiveRecord::Base
  def to_param
    name.parameterize
  end

  has_many :rewards

  def current_score
    rewards.sum(:amount)
  end
end
