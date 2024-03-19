class Observation
  attr_reader :id, :taxon_name, :taxon_observations, :common_name, :quality_grade, :taxon_rank, :time_observed_at

  def initialize(details)
    @id = details['id']
    @taxon_name = details.dig('taxon', 'name')
    @taxon_observations = details.dig('taxon', 'observations_count')
    @common_name = details.dig('taxon', 'preferred_common_name')
    @taxon_rank = details.dig('taxon', 'rank')
    @quality_grade = details['quality_grade']
    @time_observed_at = details['time_observed_at']
  end
end
