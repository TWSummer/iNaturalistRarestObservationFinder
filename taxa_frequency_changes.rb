require 'net/http'
require 'json'

class TaxaFrequencyChanges
    def initialize
        @total_counts = {}
        @taxon_counts = []
        @requests = []
    end

    def run
        pick_taxa_to_check
        get_total_counts_by_year
        get_taxa_counts_by_year
        save_results
    end

    def get_total_counts_by_year
        target_years.each do |year|
            puts "Getting the total counts for all species in #{year}"
            @total_counts[year] = get_total_count_for_year(year)
        end
    end

    def get_taxa_counts_by_year
        @target_taxa.each_with_index do |taxon, idx|
            puts "##{idx + 1} Getting the counts for #{taxon[:id]} - #{taxon[:common_name]}"
            target_years.each do |year|
                print "#{year} "
                taxon[year] = get_taxon_count_for_year(taxon, year)
            end
            puts ""

            @taxon_counts << taxon
        end
    end

    def save_results
        results = "Taxon ID,Name,Common Name,#{target_years.join(",")}\n"
        results += "Totals,,,#{target_years.map{ |year| @total_counts[year] }.join(",")}\n"
        @taxon_counts.each do |taxon|
            results += "#{taxon[:id]},#{taxon[:name]},#{taxon[:common_name]},#{target_years.map { |year| taxon[year] }.join(",")}\n"
        end
        File.open('taxon_observations_by_year.csv', 'w') do |file| 
            file.write(results)
        end
    end

    def pick_taxa_to_check
        puts "Picking taxa to check"

        response = make_request("https://api.inaturalist.org/v1/observations/species_counts?verifiable=true&identified=true&per_page=25")
        @target_taxa = response['results'].map do |result| 
            {
                id: result['taxon']['id'],
                name: result['taxon']['name'],
                common_name: result['taxon']['preferred_common_name']
            }
        end
    end

    def get_total_count_for_year(year)
        response = make_request("https://api.inaturalist.org/v1/observations?verifiable=true&identified=true&per_page=0&year=#{year}")
        response['total_results']
    end

    def get_taxon_count_for_year(taxon, year)
        response = make_request("https://api.inaturalist.org/v1/observations?verifiable=true&identified=true&per_page=0&year=#{year}&taxon_id=#{taxon[:id]}")
        response['total_results']
    end

    def make_request(url)
        # if @requests.length < 60
            
        # elsif @requests.first < Time.now - 60
        #     @requests.shift
        # else
        #     while @requests.first >= Time.now - 60
        #         sleep 0.25
        #     end
        #     p @requests.shift
        # end
        sleep(1)
        uri = URI(url)
        # @requests << Time.now
        JSON.parse(Net::HTTP.get(uri))
    end

    def target_years
        (2010..2024).to_a
    end
end

TaxaFrequencyChanges.new.run
