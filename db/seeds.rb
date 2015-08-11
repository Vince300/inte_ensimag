require 'active_record/fixtures'

# The list of classes to load
class_names = [ :users, :teams ]

# Find out the environment
e = ENV['FIXTURES_ENV'] || Rails.env
if e == "test" and not Dir.exists? Rails.root.join('db', 'seeds', 'test')
  e = "development"
end

# Get the data directory
r = Rails.root.join('db', 'seeds', e)

# Load the fixtures
ActiveRecord::Base.transaction do
  ActiveRecord::FixtureSet.create_fixtures(r, class_names)

  # Apply save method to all classes
  invalid_models = []

  class_names.map { |s| s.to_s.classify.constantize } .each do |cls|
    cls.all.each do |model|
      unless model.valid?
        invalid_models << model
      else
        model.save
      end
    end
  end

  if invalid_models.length > 0
    puts "Invalid models have been found:"
    puts invalid_models.inspect
    raise "Aborted database seeding"
  end
end
