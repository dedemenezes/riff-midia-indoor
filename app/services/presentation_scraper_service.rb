class PresentationScraperService
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
  }.freeze

  BASE_URL = "https://www.riomarket.com.br"
  PROGRAMMING_URL = "#{BASE_URL}/br/programacao"

  def self.call
    new.call
  end

  def call
    scrape_events
    generate_csv
    events
  end

  private

  attr_reader :events

  def initialize
    @events = []
  end

  def scrape_events
    html_doc.search(".accordion-group").each_with_index do |accordion, index|
      event_date = accordion.search('.accordion-toggle').first.text.strip
      Rails.logger.info "Scraping events for #{event_date}"

      accordion.search(".eventos_gratuitos").each do |element|
        event = extract_event_data(element, event_date)
        @events << event
        Rails.logger.info "✅ Added #{event[:title]}"
      end
    end
  end

  def extract_event_data(element, event_date)
    event = {}

    element.search('td').each_with_index do |td, index|
      case index
      when 0
        extract_times(td, event, event_date)
      when 1
        extract_title_and_category(td, event)
      when 2
        event[:room_id] = td.text.strip
      when 3
        extract_presenters(td, event)
      end
    end

    event
  end

  def extract_times(td, event, event_date)
    start_time, end_time = td.text.strip.split('-').map(&:strip)
    event_date_en = translate_date(event_date)
    event[:start_time] = Time.zone.strptime("#{event_date_en} #{start_time}", "%d de %B de %Y %H:%M")
    event[:end_time] = Time.zone.strptime("#{event_date_en} #{end_time}", "%d de %B de %Y %H:%M")
  end

  def extract_title_and_category(td, event)
    tipo = td.search('strong').first.text
    titulo = td.text.gsub(tipo, '').strip
    event[:category] = tipo.capitalize
    event[:title] = titulo
  end

  def extract_presenters(td, event)
    link = td.search('a').first.attribute("href").value
    detail_html = URI.parse("#{BASE_URL}#{link}").read
    detail_doc = Nokogiri::HTML.parse(detail_html)

    presenters = []
    detail_doc.search(".table tr:not(:first-child)").each do |row|
      first_td = row.at("td")&.text&.strip
      presenters << first_td if first_td.present?
    end

    event[:presenter_name] = presenters.join(", ")
  end

  def translate_date(date)
    date.gsub(/\b#{MONTHS.keys.join('|')}\b/, MONTHS)
  end

  def html_doc
    @html_doc ||= begin
      html_file = URI.parse(PROGRAMMING_URL).read
      Nokogiri::HTML.parse(html_file)
    end
  end

  def generate_csv
    csv_path = Rails.root.join('tmp', 'scraped_presentations.csv')

    CSV.open(csv_path, "wb") do |csv|
      csv << csv_headers
      events.each do |event|
        csv << csv_row(event)
      end
    end

    csv_path
  end

  def csv_headers
    [:title, :start_time, :end_time, :active, :room_id, :presenter_name, :category, :description]
  end

  def csv_row(event)
    [
      event[:title],
      event[:start_time],
      event[:end_time],
      event[:active] || false,
      event[:room_id],
      event[:presenter_name],
      event[:category],
      event[:description] || ""
    ]
  end
end
