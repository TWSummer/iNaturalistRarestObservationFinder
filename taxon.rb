class Taxon
  attr_reader :local_observations, :total_observations, :name, :common_name, :rank

  def initialize(details)
    @local_observations = details.dig('count')
    @total_observations = details.dig('taxon', 'observations_count')
    @name = details.dig('taxon', 'name')
    @common_name = details.dig('taxon', 'preferred_common_name')
    @rank = details.dig('taxon', 'rank')
  end
end
