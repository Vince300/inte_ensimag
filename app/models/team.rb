class Team < ActiveRecord::Base
  def to_param
    name.parameterize
  end
end
