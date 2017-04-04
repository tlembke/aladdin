# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Pref.delete_all
Pref.create(name: "clinic", value: "Acme Clinic")
Pref.create(name: "address", value: "61 Main St")
Pref.create(name: "suburb", value: "AladdinVille")
Pref.create(name: "phone", value: "02 66280505")

