require 'pry-byebug'
require "open-uri"
require "nokogiri"
require 'csv'

MONTHS = {
  "Janeiro" => "January",
  "Fevereiro" => "February",
  "Março" => "March",
  "Abril" => "April",
  "Maio" => "May",
  "Junho" => "June",
  "Julho" => "July",
  "Agosto" => "August",
  "Setembro" => "September",
  "Outubro" => "October",
  "Novembro" => "November",
  "Dezembro" => "December"
}
base_url = "https://www.riomarket.com.br"
url = "#{base_url}/br/programacao"


html_file = URI.parse(url).read
html_doc = Nokogiri::HTML.parse(html_file)

# tbs[0].querySelectorAll('td').forEach((td, index) => {

# })
events = []

html_doc.search(".accordion-group").first(1).each_with_index do |accordion, index|

  event_date = accordion.search('.accordion-toggle').first.text.strip
  puts "Scraping events for #{event_date}"
  puts "---"

  accordion.search(".eventos_gratuitos").first(1).each do |element|
    event = {}

    element.search('td').each_with_index do |td, index|
      if (index === 0)
          start_time, end_time = td.text.strip.split('-').map(&:strip)
          event_date_en = event_date.gsub(/\b#{MONTHS.keys.join('|')}\b/, MONTHS)
          event[:start_time] = DateTime.strptime("#{event_date_en} #{start_time}", "%d de %B de %Y %H:%M")
          event[:end_time] = DateTime.strptime("#{event_date_en} #{end_time}", "%d de %B de %Y %H:%M")
      end
      if (index === 1)
          tipo = td.search('strong').first.text
          titulo = td.text.gsub(tipo, '')
          event[:category] = tipo.capitalize
          event[:title] = titulo
      end
      if (index === 2)
          sala = td.text
          event[:room_id] = sala
      end
      if (index == 3)
          link = td.search('a').first.attribute("href").value
          html_file = URI.parse("https://www.riomarket.com.br#{link}").read
          html_doc = Nokogiri::HTML.parse(html_file)
          # p html_doc.search('tr:not(:first-child)').text.strip
          presenters = []
          html_doc.search(".table tr:not(:first-child)").each_with_index do |row, row_index|
            # p row
            first_td = row.at("td")&.text&.strip
            presenters << first_td
          end
          # puts(link)
          event[:presenter_name] = presenters.join(", ")
      end
    end
    p event
    events << event
    puts "✅ Added #{event[:title]}"
    puts "---"
  end
end
# Rails.root.join("db", "data", "from_web", "presentation.csv")
CSV.open('from_web/presentation.csv', "wb") do |csv|
  csv << events.first.keys
  events.each do |event|
    csv << [
      event[:title],
      event[:start_time],
      event[:end_time],
      event[:active],
      event[:room_id],
      event[:presenter_name],
      event[:category],
      event[:description]
    ]
   end
end
