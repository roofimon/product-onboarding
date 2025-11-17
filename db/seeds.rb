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
  admin.status = :active
  admin.save!
  puts "Admin user created: admin@example.com / admin123"
else
  # Reset password if user already exists
  admin.update!(
    name: 'Admin',
    surname: 'User',
    password: 'admin123',
    password_confirmation: 'admin123',
    admin: true,
    status: :active
  )
  puts "Admin user password reset: admin@example.com / admin123"
end

# Get or create a sample user for products
sample_user = User.where(admin: false, status: :active).first
if sample_user.nil?
  sample_user = User.find_or_initialize_by(email: 'seller@example.com')
  if sample_user.new_record?
    sample_user.name = 'John'
    sample_user.surname = 'Seller'
    sample_user.password = 'seller123'
    sample_user.password_confirmation = 'seller123'
    sample_user.admin = false
    sample_user.status = :active
    sample_user.save!
    puts "Sample user created: seller@example.com / seller123"
  end
end

# Create 7 sample products
sample_products = [
  {
    name: "Vintage Watch Collection",
    description: "A stunning collection of vintage timepieces from the 1960s-1980s. Includes Swiss-made mechanical watches, classic designs, and rare limited editions. All watches have been professionally serviced and are in excellent working condition. Perfect for collectors and watch enthusiasts.",
    open_price: 2500.00,
    price_per_bid: 100.00
  },
  {
    name: "Antique Furniture Set",
    description: "Beautiful Victorian-era furniture set including a mahogany dining table, six matching chairs, and a sideboard. Handcrafted in the late 1800s, these pieces feature intricate carvings and original hardware. Excellent condition with minor wear consistent with age. A true statement piece for any home.",
    open_price: 4500.00,
    price_per_bid: 250.00
  },
  {
    name: "Rare Coin Collection",
    description: "Comprehensive collection of rare and valuable coins spanning multiple centuries. Includes gold coins, silver pieces, and commemorative editions from various countries. Many coins are in mint condition and come with certification. A valuable investment opportunity for numismatists.",
    open_price: 8000.00,
    price_per_bid: 500.00
  },
  {
    name: "Designer Handbag",
    description: "Authentic luxury designer handbag in pristine condition. Made from premium leather with gold-tone hardware. Includes original dust bag, authenticity card, and care instructions. A timeless classic that never goes out of style. Perfect for fashion enthusiasts and collectors.",
    open_price: 1200.00,
    price_per_bid: 50.00
  },
  {
    name: "Vintage Vinyl Records",
    description: "Rare collection of vintage vinyl records from the 1960s-1980s. Includes first pressings, limited editions, and signed albums from legendary artists. All records are in excellent condition with original sleeves and inserts. A treasure trove for music collectors and audiophiles.",
    open_price: 1500.00,
    price_per_bid: 75.00
  },
  {
    name: "Art Painting",
    description: "Original oil painting by a renowned contemporary artist. Features vibrant colors and expressive brushwork in a modern abstract style. The piece is professionally framed and ready to hang. Certificate of authenticity included. A beautiful addition to any art collection or home decor.",
    open_price: 3500.00,
    price_per_bid: 200.00
  },
  {
    name: "Collectible Comic Books",
    description: "Rare collection of vintage comic books from the Golden and Silver Age of comics. Includes first appearances of iconic characters, key storylines, and limited edition issues. All comics are professionally graded and stored in protective cases. A must-have for serious comic book collectors.",
    open_price: 6000.00,
    price_per_bid: 300.00
  }
]

sample_products.each do |product_data|
  product = Product.find_or_initialize_by(name: product_data[:name], user: sample_user)
  if product.new_record?
    product.description = product_data[:description]
    product.open_price = product_data[:open_price]
    product.price_per_bid = product_data[:price_per_bid]
    product.save!
    puts "Created product: #{product.name}"
  else
    puts "Product already exists: #{product.name}"
  end
end

puts "Seeding completed! Created #{Product.count} products."
