@teams.each do |team|
  json.set! team.to_param do
    json.name team.name

    json.score do
      json.value team.current_score
      json.text t("inte.points", count: team.current_score)
    end

    json.rank do
      json.value team.rank
      json.text t("inte.position.#{team.rank}")
    end
  end
end
