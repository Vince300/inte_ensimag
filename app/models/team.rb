class Team < ActiveRecord::Base
  def to_param
    name.parameterize
  end

  has_many :rewards
end
