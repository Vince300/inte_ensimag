epoch = Date.new(1970, 1, 1)

json.series @data do |k, v|
  json.name k
  json.color v[:team_color]
  json.data v[:data].map { |pair| [ (pair[0] - epoch).to_i * 86400000, pair[1] ] }
end