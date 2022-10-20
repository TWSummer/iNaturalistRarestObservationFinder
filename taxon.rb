class Taxon
  attr_reader :local_observations, :total_observations, :name, :common_name, :rank

  def initialize(details)
    @local_observations = details.dig('count')
    @total_observations = details.dig('taxon', 'observations_count')
    @name = details.dig('taxon', 'name')
    @common_name = details.dig('taxon', 'preferred_common_name')
    @rank = details.dig('taxon', 'rank')


    # @taxon_name = details.dig('taxon', 'name')
    # @taxon_observations = details.dig('taxon', 'observations_count')
    # @common_name = details.dig('taxon', 'preferred_common_name')
    # @taxon_rank = details.dig('taxon', 'rank')
    # @quality_grade = details['quality_grade']
    # @time_observed_at = details['time_observed_at']
  end
end


{
  "total_results"=>5835,
  "page"=>1,
  "per_page"=>1,
  "results"=>[
    {
      "count"=>3205,
      "taxon"=>{
        "observations_count"=>93774,
        "taxon_schemes_count"=>9,
        "is_active"=>true,
        "ancestry"=>"48460/1/2/355675/3/7251/7823/7998",
        "flag_counts"=>{"resolved"=>1, "unresolved"=>0},
        "wikipedia_url"=>"http://en.wikipedia.org/wiki/American_crow",
        "current_synonymous_taxon_ids"=>nil,
        "iconic_taxon_id"=>3,
        "rank_level"=>10,
        "taxon_changes_count"=>0,
        "atlas_id"=>nil,
        "complete_species_count"=>nil,
        "parent_id"=>7998,
        "complete_rank"=>"subspecies",
        "name"=>"Corvus brachyrhynchos",
        "rank"=>"species",
        "extinct"=>false,
        "id"=>8021,
        "default_photo"=>{"id"=>24115, "license_code"=>"cc-by-nc", "attribution"=>"(c) Joe McKenna, some rights reserved (CC BY-NC)", "url"=>"https://inaturalist-open-data.s3.amazonaws.com/photos/24115/square.jpg", "original_dimensions"=>{"height"=>1448, "width"=>2048}, "flags"=>[], "square_url"=>"https://inaturalist-open-data.s3.amazonaws.com/photos/24115/square.jpg", "medium_url"=>"https://inaturalist-open-data.s3.amazonaws.com/photos/24115/medium.jpg"},
        "ancestor_ids"=>[48460, 1, 2, 355675, 3, 7251, 7823, 7998, 8021],
        "iconic_taxon_name"=>"Aves",
        "preferred_common_name"=>"American Crow",
        "establishment_means"=>{"establishment_means"=>"native", "id"=>6975, "place"=>{"id"=>14, "name"=>"California", "display_name"=>"California, US", "ancestry"=>"97394/1"}},
        "preferred_establishment_means"=>"native"
      }
    }
  ]
}
