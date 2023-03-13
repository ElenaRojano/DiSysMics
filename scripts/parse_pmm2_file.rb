#! /usr/bin/env ruby

#

##############################
#LIBRARIES
##############################

require 'optparse'

##############################
#METHODS
##############################

def paco_parser(input_file, output_file, gene_coords)
	data = {}
	File.open(input_file).each do |line|
		line.chomp!
		pmm2_info = line.split("\t")
		header = pmm2_info.shift
		if header.include?('Patient')
			data = Hash[pmm2_info.collect { |item| [item, []] } ]
		else
			header =~ /([^:]*)(HP:\d{7})/
			hpo_name = $1
			hpo_code = $2
			data.keys.each do |patient|
				phen = pmm2_info.shift
				if phen == "1"
					data[patient] << hpo_code.gsub(/\s+/, "") #HPO to save
				end
			end			
		end
	end
	# info = data.values.map{|v| v.length}
	# STDERR.puts info.sort.inspect
	# STDERR.puts info.inject{|sum,n| sum + n}.fdiv(info.length)
	# Process.exit
	
	File.open(output_file, 'w') do |file|
		file.puts "patient_id\tchr\tstart\tstop\tphenotypes"
		data.each do |patient, hpos|
			file.puts "#{patient}\t#{gene_coords.split(':').join("\t")}\t#{hpos.join(',')}"
		end
	end
end

##############################
#OPTPARSE
##############################

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  options[:gene_coords] = '16:8891670:8943194'
  opts.on("-g", "--gene_coords STRING", "Gene coordinates separated by : (chr:start:stop)") do |data|
    options[:gene_coords] = data
  end
  
  options[:input_file] = nil
  opts.on("-i", "--input_file PATH", "Input pmm2 file") do |data|
    options[:input_file] = data
  end

  options[:output_file] = 'pmm2_paco_format.txt'
  opts.on("-o", "--output_file PATH", "Output PACO file format") do |data|
    options[:output_file] = data
  end


end.parse!

##############################
#MAIN
##############################

paco_parser(options[:input_file], options[:output_file], options[:gene_coords])