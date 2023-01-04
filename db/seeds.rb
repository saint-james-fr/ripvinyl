puts "----"
puts "Destroying Data"
puts "..."
Release.destroy_all
User.destroy_all
puts "Done!"

puts "----"
puts "Creating User"
puts "..."
User.create!(email: "test@test.com", password: "test")
puts "Done!"
