# User.destroy_all
# User.create!(email: 'admin@festivaldorio.com.br', password: 'festrio2025', admin: true)

# Clear existing data
puts "🗑️  Clearing existing data..."
Presentation.destroy_all
Room.destroy_all

# Create rooms
puts "🏢 Creating rooms..."
room_names = [1, 2, 3, 5].map { |n| "Sala #{n}"}

rooms = room_names.map do |name|
  Room.create!(name: name)
end

puts "✅ Created #{rooms.count} rooms"

# Create presentations
puts "🎭 Creating presentations..."
# db/seeds.rb
require 'faker'

rooms = Room.all.to_a
raise "No rooms found! Create some rooms first." if rooms.empty?

now = Time.current

# Helper to generate sequential presentations per room
def create_presentations_for_room(room, day, now)
  start_time = day.to_time.change({ hour: 7, min: 25 }) # 4:00 PM
  duration = 5.minutes # each presentation 1h20
  4.times do |i|
    end_time = start_time + duration
    Presentation.create!(
      title: Faker::Book.title,
      start_time: start_time,
      end_time: end_time,
      active: start_time <= now && now < end_time, # active if happening now
      room: room,
      presenter_name: Faker::Name.name,
      category: Presentation::CATEGORIES.sample,
      description: Faker::Lorem.sentence(word_count: 25)
    )
    # Next presentation starts after the previous ends
    start_time = end_time
  end
end

today = Date.today
tomorrow = today + 1

rooms.each do |room|
  create_presentations_for_room(room, today, now)
  create_presentations_for_room(room, tomorrow, now)
end

puts "✅ Created 4 sequential presentations per room for today and tomorrow. Active presentations are set automatically."

puts "🎉 Seed completed!"
puts "📊 Summary:"
puts "   - Rooms: #{Room.count}"
puts "   - Presentations: #{Presentation.count}"
puts "   - Active presentations: #{Presentation.where(active: true).count}"
# puts "   - Date range: #{start_date.strftime('%b %d')} to #{end_date.strftime('%b %d, %Y')}"
