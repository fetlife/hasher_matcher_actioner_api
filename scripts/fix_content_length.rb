#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

def fix_content_length_in_file(file_path)
  puts "Processing: #{file_path}"
  
  content = File.read(file_path)
  yaml_data = YAML.load(content)
  
  modified = false
  
  if yaml_data['http_interactions']
    yaml_data['http_interactions'].each do |interaction|
      if interaction['response'] && interaction['response']['headers'] && interaction['response']['body']
        headers = interaction['response']['headers']
        body = interaction['response']['body']
        
        if headers['Content-Length'] && body['string']
          # Calculate actual content length
          actual_length = body['string'].bytesize
          current_length = headers['Content-Length'].first.to_i
          
          if actual_length != current_length
            puts "  Fixing Content-Length: #{current_length} -> #{actual_length}"
            headers['Content-Length'] = [actual_length]
            modified = true
          end
        end
      end
    end
  end
  
  if modified
    File.write(file_path, yaml_data.to_yaml)
    puts "  Updated file"
  else
    puts "  No changes needed"
  end
end

# Find all VCR yml files
vcr_dir = File.join(__dir__, 'spec', 'vcr_cassettes')
yml_files = Dir.glob(File.join(vcr_dir, '**', '*.yml'))

puts "Found #{yml_files.length} VCR files to process"

yml_files.each do |file_path|
  fix_content_length_in_file(file_path)
end

puts "Done!"
