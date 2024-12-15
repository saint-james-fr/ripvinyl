# lib/tasks/create_admin.rake
namespace :admin do
  desc "Create an admin user in production"
  task create: :environment do
    print "Enter admin email: "
    email = STDIN.gets.chomp

    print "Enter admin password: "
    password = STDIN.gets.chomp

    if email.empty? || password.empty?
      puts "Error: Email and password cannot be blank"
      exit 1
    end

    user = User.create!(
      email: email,
      password: password,
    )

    puts "\nAdmin user created successfully!"
    puts "Email: #{user.email}"
  rescue ActiveRecord::RecordInvalid => e
    puts "\nError creating admin user:"
    puts e.record.errors.full_messages.join("\n")
    exit 1
  end
end
