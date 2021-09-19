require 'uri'
require 'net/http'
require 'json'
require 'nokogiri'
require 'yaml'
require 'csv'

require_relative '../utilities_and_monkey_patching.rb'
require_relative 'builds.rb'
require_relative 'csv_row_validator.rb'

class Builds::GenerateCsv
  def initialize(yml_file_name:'all-builds.yml', result_file_name: 'builds.csv')
    @all_builds = YAML.load_file(yml_file_name)
    @result_file_name = result_file_name
    @row_line_number = 2
  end

  def run
    CSV.open(Dir.getwd + '/' + @result_file_name, 'w+', col_sep: '|') do |builds_csv|
      builds_csv << Builds::CsvRowValidator::ROW_HEADERS_TO_VIEW_PREP.keys.map { |h| titleize(h) }
    
      @all_builds.each do |bd| # bd is build_data
        # Grabbing build data to get the calculated stats of the character
        uri = URI(bd['build_link'])
        response = Net::HTTP.get(uri)
        build_stats = JSON.parse(Nokogiri::HTML.parse(response).css(".builds")[0].children[1].attributes["data"].value)['build']['build_stats']
      
        weapon1_dmg  = build_stats['weapon1']
        weapon2_dmg  = build_stats['weapon2']
        phys_armor   = build_stats['armor']['phys']
        elem_armor   = build_stats['armor']['elem']
        weight_class = build_stats['weight_class']
      
        row_arr = [ # Order of data matters here. Should match same order of headers in csv_row_validator.rb
          bd['role'], 
          bd['pvp_or_pve'], 
          bd['weapon1'], 
          bd['weapon2'], 
          bd['build_variant'], 
          bd['role_gist'], 
          bd['strengths'], 
          bd['weaknesses'], 
          'N/A', 
          weapon1_dmg,
          weapon2_dmg, 
          phys_armor,
          elem_armor,
          weight_class,
          bd['build_link']
        ]
    
        check_valid_row_and_raise_possible_errors(row_arr)
        
        builds_csv << prep_csv_row_data_for_csv(row_arr)
        @row_line_number += 1
      end
    end
  end

private

  def check_valid_row_and_raise_possible_errors(row_arr)
    row_validator = Builds::CsvRowValidator.new(row_arr)
    unless row_validator.valid?
      raise RuntimeError.new("Issue(s) found while processing line number #{@row_line_number}: #{row_validator.errors.join(', ')}")
    end
  end

  def titleize(str)
    str.split('_').map { |w| w.capitalize }.join(' ')
  end

  def format_list(arr)
    arr.map { |str| "- #{str}\n" }.join
  end

  def prep_csv_row_data_for_csv(row_arr)
    Builds::CsvRowValidator::ROW_HEADERS_TO_VIEW_PREP.each_with_index do |(header, prep_method), idx|
      case prep_method
      when Builds::CsvRowValidator::FORMAT_LIST
        row_arr[idx] = format_list(row_arr[idx])
      when Builds::CsvRowValidator::TITLEIZE
        row_arr[idx] = titleize(row_arr[idx])
      end
    end

    row_arr
  end
end

Builds::GenerateCsv.new.run