require 'net/http'
require 'json'
require './taxon.rb'

class RareTaxaNearby
  TAXA_PER_PAGE = 200
  NUM_RAREST_TO_DISPLAY = 100
  SEARCH_RANGE = 0.2 # degrees latitude and longitude around center
  EXCLUDE_RANKS = %w[hybrid].freeze

  def run
    collect_inputs
    fetch_taxa
    display_results
  end

  def collect_inputs
    get_location
    get_parent_taxon
    get_month
  end

  def get_location
    puts 'Enter latitude of location (-90.0 to 90.0)'
    @latitude = gets.chomp.to_f

    puts 'Enter longitude of location (-180.0 to 180.0)'
    @longitude = gets.chomp.to_f
  end

  def get_parent_taxon
    puts 'Only include taxa that are within this taxon ID (animals = 1, plants = 47126, leave blank for any):'
    @parent_taxon_id = gets.chomp
  end

  def get_month
    puts 'Only include observations from these months ("10,11" = October and November, leave blank for any)'
    @months = gets.chomp
  end

  def fetch_taxa
    @taxa = []
    puts "Looking up taxa #{"within taxon_id #{@parent_taxon_id} " if @parent_taxon_id}#{"from the months #{@months} " if @months}observed near  #{@latitude}, #{@longitude}"
    total_taxa = get_local_taxa_count
    puts "There are #{total_taxa} that have been observed in your area!"

    (total_taxa.to_f / TAXA_PER_PAGE).ceil.times do |page|
      puts "Fetching taxa #{(page * TAXA_PER_PAGE) + 1} to #{(page + 1) * TAXA_PER_PAGE}"
      uri = URI("#{base_url}&page=#{page + 1}&per_page=#{TAXA_PER_PAGE}")
      request_result = JSON.parse(Net::HTTP.get(uri))
      @taxa << request_result['results']
    end
    @taxa.flatten!
    @taxa.map!{|details| Taxon.new(details) }
  end

  def display_results
    puts "Here are the #{NUM_RAREST_TO_DISPLAY} rarest taxa near #{@latitude}, #{@longitude}"
    @taxa.reject! { |taxon| EXCLUDE_RANKS.include?(taxon.rank) }
    @taxa.sort! { |a, b| a.total_observations <=> b.total_observations }

    NUM_RAREST_TO_DISPLAY.times do |num|
      taxon = @taxa[num]
      next unless taxon
      
      puts "#{num + 1}. #{taxon.rank} #{taxon.common_name} (#{taxon.name}) has #{taxon.total_observations} total observations, of which #{taxon.local_observations} are local."
    end
  end

  private

  def base_url
    @base_url ||= "https://api.inaturalist.org/v1/observations/species_counts?verifiable=true&nelat=#{max_latitude}&nelng=#{max_longitude}&swlat=#{min_latitude}&swlng=#{min_longitude}&locale=en#{taxon_query}#{month_query}"
  end

  def taxon_query
    return '' unless @parent_taxon_id
    "&taxon_id=#{@parent_taxon_id}"
  end

  def month_query
    return '' unless @months
    "&month=#{@months}"
  end

  def get_local_taxa_count
    uri = URI("#{base_url}&page=1&per_page=1")
    basic_details = JSON.parse(Net::HTTP.get(uri))
    basic_details['total_results']
  end

  def min_latitude
    return @min_latitude if @min_latitude
    @min_latitude = @latitude - SEARCH_RANGE
    @min_latitude = -90 if @min_latitude < -90

    @min_latitude
  end

  def max_latitude
    return @max_latitude if @max_latitude
    @max_latitude = @latitude + SEARCH_RANGE
    @max_latitude = 90 if @max_latitude > 90

    @max_latitude
  end

  def min_longitude
    return @min_longitude if @min_longitude
    @min_longitude = @longitude - SEARCH_RANGE
    @min_longitude = @min_longitude + 360 if @min_longitude < -180

    @min_longitude
  end

  def max_longitude
    return @max_longitude if @max_longitude
    @max_longitude = @longitude + SEARCH_RANGE
    @max_longitude = @max_longitude - 360 if @max_longitude > 180

    @max_longitude
  end
end

RareTaxaNearby.new.run
