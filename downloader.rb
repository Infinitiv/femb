#!/usr/bin/ruby

url = 'http://193.232.7.120/feml/clinical_ref/'
referer = 'http://www.femb.ru/'
link = '/HTML/files/assets/mobile/pages/'

list = %x(curl -s -e "#{referer}" "#{url}").scan(/\d{10}S/).uniq
n = 0
nn = list.length
list.each do |i|
  n += 1
  begin
    title = %x(curl -s -e "#{referer}" "#{[url, i, 'HTML/'].join('/')}").scan(/<title>(.*)<\/title>/).first.first.strip
  rescue
    title = i
  end
  %x(mkdir -p "#{i}")
  pics = %x(curl -s -e "#{referer}" "#{[url, i, link].join}").scan(/(page\w*2.png|page\w*2.jpg|page\w*2.jpeg)/).uniq
  pics.each do |pic|
    %x(curl -s -e "#{referer}" "#{[url, i, link, pic.first].join}" -o "#{[i, pic.first].join('/')}")
#     %x(tesseract -l rus "#{[i, pic.first].join('/')}" "#{[i, pic.first].join('/').scan(/(.*)\./).first.first}" pdf)
#     %x(rm "#{[i, pic.first].join('/')}")
  end
  %x(mv "#{i}" "#{title.split(". ").last}") unless title == i
  puts "Загружено #{n} из #{nn} - #{(n.to_f/nn*100).round(2)}%"
end