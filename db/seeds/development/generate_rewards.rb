require 'yaml'
require 'active_support/time'

dt = DateTime.now
teams = %w( agario akinawa kawabunga ensihaka )
rewards = {}

800.times do |i|
  # Go back 1 to 30 mins in the past
  dt -= (1 + rand(29)).minutes

  # Pick a random team
  team = teams.sample

  # Pick an amount
  amount = rand(50)

  # Add to rewards
  rewards["reward_#{i}"] = {
    'subject' => "Reward #{i}",
    'team' => team,
    'amount' => amount,
    'created_at' => (dt - 2.hours).to_formatted_s(:db)
  }
end

File.write('rewards.yml', YAML.dump(rewards))
