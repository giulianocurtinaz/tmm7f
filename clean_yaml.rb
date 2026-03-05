require 'fileutils'

Dir.glob('_genealogia/*.md').each do |file|
  content = File.read(file, encoding: 'bom|utf-8')
  clean_content = content.gsub(/[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F-\x9F]/, '')
  File.write(file, clean_content, encoding: 'utf-8')
  puts "Cleaned: #{file}"
end
