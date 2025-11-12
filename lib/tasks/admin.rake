namespace :admin do
  desc "Create admin user"
  task create_admin: :environment do
    admin = User.find_or_create_by(email: "admin@example.com") do |user|
      user.name = "Admin"
      user.surname = "User"
      user.password = "password"
      user.password_confirmation = "password"
      user.admin = true
    end

    if admin.persisted?
      puts "Admin user created successfully!"
      puts "Email: admin@example.com"
      puts "Password: password"
    else
      puts "Error creating admin user:"
      puts admin.errors.full_messages.join(", ")
    end
  end
end