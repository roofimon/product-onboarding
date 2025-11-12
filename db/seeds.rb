# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create or update admin user
admin = User.find_or_initialize_by(email: 'admin@example.com')
if admin.new_record?
  admin.name = 'Admin'
  admin.surname = 'User'
  admin.password = 'admin123'
  admin.password_confirmation = 'admin123'
  admin.admin = true
  admin.save!
  puts "Admin user created: admin@example.com / admin123"
else
  # Reset password if user already exists
  admin.update!(
    name: 'Admin',
    surname: 'User',
    password: 'admin123',
    password_confirmation: 'admin123',
    admin: true
  )
  puts "Admin user password reset: admin@example.com / admin123"
end
