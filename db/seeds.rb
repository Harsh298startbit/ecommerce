# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding collections..."

collections = [
  {
    name: "Vegetables",
    description: "Fresh and organic vegetables"
  },
  {
    name: "Fruits",
    description: "Fresh and juicy fruits"
  },
  {
    name: "Juice",
    description: "Natural and healthy juices"
  },
  {
    name: "Dried",
    description: "Dried fruits and vegetables"
  }
]

collections.each do |collection_attrs|
  collection = Collection.find_or_create_by(name: collection_attrs[:name]) do |c|
    c.description = collection_attrs[:description]
  end
  
  if collection.persisted?
    puts "✓ Created/Found collection: #{collection.name}"
  else
    puts "✗ Failed to create collection: #{collection_attrs[:name]} - #{collection.errors.full_messages.join(', ')}"
  end
end

puts "\nSeeding users..."

# Create Admin User
admin = User.find_or_create_by(email: "admin@example.com") do |u|
  u.name = "Admin User"
  u.password = "admin123"
  u.password_confirmation = "admin123"
  u.is_admin = true
end

if admin.persisted?
  puts "✓ Created/Found admin user: #{admin.email}"
  puts "  Login with: admin@example.com / admin123"
else
  puts "✗ Failed to create admin user: #{admin.errors.full_messages.join(', ')}"
end

# Create Sample Customer
customer = User.find_or_create_by(email: "customer@example.com") do |u|
  u.name = "Customer User"
  u.password = "customer123"
  u.password_confirmation = "customer123"
  u.is_admin = false
end

if customer.persisted?
  puts "✓ Created/Found customer user: #{customer.email}"
  puts "  Login with: customer@example.com / customer123"
else
  puts "✗ Failed to create customer user: #{customer.errors.full_messages.join(', ')}"
end

puts "\nSeeding completed!"
puts "Total collections: #{Collection.count}"
puts "Total users: #{User.count}"
puts "Total admins: #{User.where(is_admin: true).count}"
