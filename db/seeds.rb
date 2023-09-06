puts "----"
puts "Destroying Data"
puts "..."
Release.destroy_all
User.destroy_all
puts "Done!"

puts "----"
puts "Creating User"
puts "..."
User.create!(email: "maxencerobinet@gmail.com", password: "password")
puts "Done!"
