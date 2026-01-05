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

puts "\nSeeding completed!"
puts "Total collections: #{Collection.count}"
