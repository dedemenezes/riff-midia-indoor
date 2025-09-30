User.destroy_all
User.create!(email: 'admin@festivaldorio.com.br', password: 'festrio2025', admin: true)

# Clear existing data
puts "🗑️  Clearing existing data..."
Presentation.destroy_all
Room.destroy_all

# Create rooms
puts "🏢 Creating rooms..."
room_names = [
  "Auditorium Alpha",
  "Conference Beta",
  "Workshop Gamma",
  "Meeting Delta",
  "Presentation Epsilon"
]

rooms = room_names.map do |name|
  Room.create!(name: name)
end

puts "✅ Created #{rooms.count} rooms"

# Create presentations
puts "🎭 Creating presentations..."

# Continuous 6-day date range starting today (including weekends)
start_date = Date.today
end_date = start_date + 1.day
date_range = (start_date..end_date).to_a

# Presentation topics for variety
tech_topics = [
  "Introduction to AI", "Machine Learning Basics", "Web Development Trends",
  "Data Science Applications", "Cloud Computing", "Cybersecurity Essentials",
  "Mobile App Development", "DevOps Practices", "Blockchain Technology",
  "UX/UI Design Principles", "API Design Patterns", "Database Optimization",
  "Microservices Architecture", "Agile Methodologies", "Software Testing",
  "Digital Transformation", "IoT Applications", "Serverless Computing",
  "Progressive Web Apps", "React Best Practices", "Python for Beginners",
  "JavaScript Frameworks", "Docker Fundamentals", "Git Version Control"
]

presentation_count = 0

date_range.each do |date|
  # Track used time slots to avoid conflicts per room
  room_schedules = Hash.new { |h, k| h[k] = [] }

  # Ensure each room gets 2–3 presentations per day
  rooms.each do |room|
    presentations_for_room = rand(2..3)

    presentations_for_room.times do
      max_attempts = 10
      attempt = 0

      loop do
        attempt += 1
        break if attempt > max_attempts

        # Generate random time between am and 3:45pm
        hour = rand(9..15)
        minute = [0, 15, 30, 45].sample

        start_time = date.beginning_of_day + hour.hours + minute.minutes

        # Duration: 45 minutes to 1.5 hours
        duration = [45, 60, 75, 90].sample.minutes
        end_time = start_time + duration

        # Skip if end time goes past 5:30pm
        next if end_time > date.beginning_of_day + 17.5.hours

        # Ensure no conflicts in same room (15 min buffer)
        conflict = room_schedules[room.id].any? do |existing_time|
          (start_time - existing_time).abs < 75.minutes
        end

        unless conflict
          room_schedules[room.id] << start_time

          presentation = Presentation.create!(
            title: tech_topics.sample,
            presenter_name: Faker::Name.name,
            start_time: start_time,
            end_time: end_time,
            room: room,
            active: false # Start as inactive
          )

          presentation_count += 1
          break
        end
      end
    end
  end
end

puts "✅ Created #{presentation_count} presentations"

# Activate one current/upcoming presentation per room for demo
puts "🎯 Activating current presentations..."

rooms.each do |room|
  # Find a presentation that's either happening now or starting soon
  current_or_upcoming = room.presentations
    .where("start_time >= ?", Time.current - 1.hour)
    .order(:start_time)
    .first

  if current_or_upcoming
    current_or_upcoming.update!(active: true)
    puts "   📍 Activated: #{current_or_upcoming.title} in #{room.name}"
  end
end

puts "🎉 Seed completed!"
puts "📊 Summary:"
puts "   - Rooms: #{Room.count}"
puts "   - Presentations: #{Presentation.count}"
puts "   - Active presentations: #{Presentation.where(active: true).count}"
puts "   - Date range: #{start_date.strftime('%b %d')} to #{end_date.strftime('%b %d, %Y')}"
