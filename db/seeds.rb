User.destroy_all
Room.destroy_all

User.create!(email: 'admin@festivaldorio.com.br', password: 'festrio2025', admin: true)
p User.last
Room.create! [
  { name: 'Sala 1' },
  { name: 'Sala 2' },
  { name: 'Sala 3' },
  { name: 'Lounge' }
]
p Room.last
