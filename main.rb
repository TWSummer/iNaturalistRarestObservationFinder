require 'net/http'
require 'json'

class Observation
  attr_reader :taxon_name, :taxon_observations, :common_name, :quality_grade, :taxon_rank, :time_observed_at

  def initialize(details)
    @taxon_name = details.dig('taxon', 'name')
    @taxon_observations = details.dig('taxon', 'observations_count')
    @common_name = details.dig('taxon', 'preferred_common_name')
    @taxon_rank = details.dig('taxon', 'rank')
    @quality_grade = details['quality_grade']
    @time_observed_at = details['time_observed_at']
  end
end

class ObservationFinder
  OBSERVATIONS_PER_PAGE = 200
  NUM_RAREST_TO_DISPLAY = 100

  def run
    get_username
    fetch_observations
    display_results
  end

  def get_username
    puts 'What is your username?'
    @username = gets.chomp
  end

  def fetch_observations
    @observations = []
    puts "Looking up user #{@username}"
    total_observations = determine_total_observations
    puts "Wow, you have #{total_observations} observations!"
    (total_observations.to_f / OBSERVATIONS_PER_PAGE).ceil.times do |page|
      puts "Fetching observations #{(page * OBSERVATIONS_PER_PAGE) + 1} to #{(page + 1) * OBSERVATIONS_PER_PAGE}"
      uri = URI("https://api.inaturalist.org/v1/observations?user_login=#{@username}&page=#{page + 1}&per_page=#{OBSERVATIONS_PER_PAGE}&order=desc&order_by=created_at")
      request_result = JSON.parse(Net::HTTP.get(uri))
      @observations << request_result['results']
    end
    @observations.flatten!
    @observations.map! { |details| Observation.new(details) }
  end

  def display_results
    puts "Here are the #{NUM_RAREST_TO_DISPLAY} rarest taxa that you have observed!"
    @observations.reject! { |obs| obs.taxon_observations.nil? }
    @observations.sort! { |a, b| a.taxon_observations <=> b.taxon_observations }
    NUM_RAREST_TO_DISPLAY.times do |num|
      obs = @observations[num]
      puts "#{num + 1}. You observed the #{obs.taxon_rank} #{obs.common_name} (#{obs.taxon_name}) at #{obs.time_observed_at}, which has only been observed #{obs.taxon_observations} times."
    end
  end

  def determine_total_observations
    uri = URI("https://api.inaturalist.org/v1/observations?user_login=#{@username}&page=1&per_page=1&order=desc&order_by=created_at")
    basic_details = JSON.parse(Net::HTTP.get(uri))
    basic_details['total_results']
  end
end

ObservationFinder.new.run
