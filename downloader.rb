#!/usr/bin/ruby
# объявляем переменные
url = 'http://193.232.7.120/feml/'
referer = 'http://www.femb.ru/'
link = '/HTML/files/assets/mobile/pages/'
type = 'clinical_ref/'
tmp = 'tmp'
downloads = 'downloads'

# создаем каталоги
%x(mkdir -p #{tmp})
%x(mkdir -p #{downloads})

# получаем список книг
list = %x(curl -s -e #{referer} #{url + type}).scan(/\d{10}S/).uniq

# создаем счетчики
n = 0
nn = list.length

# перебираем книги
list.each do |i|
  n += 1
  # если title содержит недопустимые символы
  begin
    # извлекаем название книги
    title = %x(curl -s -e #{referer} #{[url, type, i, 'HTML/'].join('/')}).scan(/<title>(.*)<\/title>/).first.first.strip
  rescue
    # если название не извлекается, оставляем номер
    title = i
  end
  
  # получаем список страниц
  pics = %x(curl -s -e #{referer} #{[url, type, i, link].join}).scan(/(page\w*2.png|page\w*2.jpg|page\w*2.jpeg)/).uniq
  
  # перебираем страницы
  pics.each do |pic|
    # кладем страницу во временный каталог
    %x(curl -s -e #{referer} #{[url, type, i, link, pic.first].join} -o #{[tmp, pic.first].join('/')})
    # распознаем страницу
    %x(tesseract -l rus #{[tmp, pic.first].join('/')} #{[tmp, pic.first].join('/').scan(/(.*)\./).first.first} pdf)
  end
  
  # объединяем страницы в книгу
  %x(pdfunite #{[tmp, '*.pdf'].join('/')} #{[downloads, i].join('/')}.pdf)
  # переименовываем книгу, если возможно
  %x(mv #{[downloads, i].join("/")}.pdf "#{[downloads, title.split(". ").last].join('/')}.pdf") unless title == i
  
  # очищаем временный каталог
  %x(rm #{[tmp, '*'].join('/')})
  
  # показываем сообщение о прогрессе
  puts "Загружено #{n} из #{nn} - #{(n.to_f/nn*100).round(2)}%"
end