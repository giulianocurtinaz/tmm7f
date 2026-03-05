Dir.glob('_pontos/*.md').each do |filepath|
  content = File.read(filepath)
  
  if content.include?('ordenacao:')
    puts "Skipping #{filepath} (ordenacao already exists)"
    next
  end

  if content =~ /id_ponto:\s*["']?(\d+)["']?/
    id_val = $1.to_i
    new_content = content.sub(/(id_ponto:.*)/, "\\1\nordenacao: #{id_val}")
    File.write(filepath, new_content)
    puts "Updated #{filepath}"
  else
    puts "No id_ponto found in #{filepath}"
  end
end
