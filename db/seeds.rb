User.destroy_all
User.create!(email: 'admin@festivaldorio.com.br', password: 'festrio2025', admin: true)
# db/seeds.rb

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

# Date range: October 2-7, 2025
start_date = Date.parse("2025-10-02")
end_date = Date.parse("2025-10-07")

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

(start_date..end_date).each do |date|
  # Skip weekends if you want
  next if date.saturday? || date.sunday?

  # Track used time slots to avoid conflicts per room
  room_schedules = Hash.new { |h, k| h[k] = [] }

  # Ensure each room gets 2-3 presentations per day
  rooms.each do |room|
    presentations_for_room = rand(2..3)

    presentations_for_room.times do |slot|
      # Generate non-conflicting time slots
      max_attempts = 10
      attempt = 0

      loop do
        attempt += 1
        break if attempt > max_attempts

        # Generate random time between 10am and 4pm (to leave room for end times)
        hour = rand(10..15)
        minute = [0, 15, 30, 45].sample

        start_time = date.beginning_of_day + hour.hours + minute.minutes

        # Duration: 45 minutes to 1.5 hours
        duration = [45, 60, 75, 90].sample.minutes
        end_time = start_time + duration

        # Skip if end time goes past 5:30pm
        next if end_time > date.beginning_of_day + 17.5.hours

        # Ensure no time conflicts in the same room (at least 15 min buffer)
        conflict = room_schedules[room.id].any? do |existing_time|
          (start_time - existing_time).abs < 75.minutes
        end

        # If no conflict, create the presentation
        unless conflict
          room_schedules[room.id] << start_time

          presentation = Presentation.create!(
            title: tech_topics.sample,
            presenter_name: Faker::Name.name,
            start_time: start_time,
            end_time: end_time,
            room: room,
            active: false # Start with all inactive
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
  # Find a presentation that's either happening now or soon
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
puts "   - Date range: #{Presentation.minimum(:start_time)&.strftime('%b %d')} to #{Presentation.maximum(:start_time)&.strftime('%b %d, %Y')}"
