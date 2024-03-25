require 'net/http'
require 'json'

class SpeciesCountsFrequencyChanges
    TARGET_PAGES = (1..8).freeze
    ANNUAL_CHECK_PAGES = (1..20).freeze
    TARGET_YEARS = (2010..2023).to_a.freeze

    def initialize
        @target_taxa = {}
        @total_counts = {}
        @taxon_counts = []
        @requests = []
    end

    def run
        begin
            pick_taxa_to_check
            get_total_counts_by_year
            get_taxa_counts_by_year
            fill_in_missing_taxa_counts
        rescue   
        end
        save_results
    end

    def get_total_counts_by_year
        TARGET_YEARS.each do |year|
            puts "Getting the total counts for all species in #{year}"
            @total_counts[year] = get_total_count_for_year(year)
        end
    end

    def get_taxa_counts_by_year
        TARGET_YEARS.each do |year|
            get_taxa_counts_for_year(year)
        end
    end

    def save_results
        results = "Taxon ID,Name,Common Name,#{TARGET_YEARS.join(",")}\n"
        results += "Totals,,,#{TARGET_YEARS.map{ |year| @total_counts[year] }.join(",")}\n"
        @taxon_counts.each do |taxon|
            results += "#{taxon[:id]},#{taxon[:name]},#{taxon[:common_name]},#{TARGET_YEARS.map { |year| taxon[year] }.join(",")}\n"
        end
        File.open('species_counts_by_year_v2.csv', 'w') do |file| 
            file.write(results)
        end
    end

    def pick_taxa_to_check
        puts "Picking taxa to check"

        TARGET_PAGES.each do |page|
            puts "page ##{page}"
            response = make_request("https://api.inaturalist.org/v1/observations/species_counts?verifiable=true&identified=true&per_page=500&page=#{page}&year=2019")
            response['results'].each do |result| 
                taxa_info = {
                    id: result['taxon']['id'],
                    name: result['taxon']['name'],
                    common_name: result['taxon']['preferred_common_name']
                }
                @target_taxa[taxa_info[:id]] = taxa_info
                @taxon_counts << taxa_info
            end
        end
    end

    def get_total_count_for_year(year)
        response = make_request("https://api.inaturalist.org/v1/observations?verifiable=true&identified=true&per_page=0&year=#{year}")
        response['total_results']
    end

    def get_taxa_counts_for_year(year)
        print "Fetching results for #{year}"
        ANNUAL_CHECK_PAGES.each do |page|
            print page.to_s

            response = make_request("https://api.inaturalist.org/v1/observations/species_counts?verifiable=true&identified=true&per_page=500&page=#{page}&year=#{year}")
            response['results'].each do |result|
                taxon_id = result['taxon']['id']
                taxon_info = @target_taxa[taxon_id]
                next unless taxon_info

                taxon_info[year] = result['count']
            end
        end
        puts ""
    end

    def fill_in_missing_taxa_counts
        @taxon_counts.each do |taxon|
            TARGET_YEARS.each do |year|
                next if taxon[year]
                taxon[year] = get_taxon_count_for_year(taxon, year)
            end
        end
    end

    def get_taxon_count_for_year(taxon, year)
        puts "Fetching #{taxon[:id]} - #{taxon[:common_name]} totals for #{year}"
        response = make_request("https://api.inaturalist.org/v1/observations?verifiable=true&identified=true&per_page=0&year=#{year}&taxon_id=#{taxon[:id]}")
        response['total_results']
    end

    def make_request(url)
        sleep(1)

        begin
            uri = URI(url)
            JSON.parse(Net::HTTP.get(uri))
        rescue
            puts "Request failed, retrying"
            sleep(60)
            uri = URI(url)
            JSON.parse(Net::HTTP.get(uri))
        end
    end
end

SpeciesCountsFrequencyChanges.new.run
