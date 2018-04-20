if Regime.count.zero?
  Regime.create!(name: 'PAS', title: 'Installations')
  Regime.create!(name: 'CFD', title: 'Water Quality')
  Regime.create!(name: 'WML', title: 'Waste')
end

r = Regime.find_by!(slug: 'pas')
r.permit_categories.destroy_all
PermitCategoryImporter.import(r, Rails.root.join('db', 'categories', 'installations.csv'))

%w[ A B E N S Y ].each do |region|
  SequenceCounter.find_or_create_by(regime_id: r.id, region: region)
end

r = Regime.find_by!(slug: 'cfd')
r.permit_categories.destroy_all
PermitCategoryImporter.import(r, Rails.root.join('db', 'categories', 'water_quality.csv'))

%w[ A B E N S T Y ].each do |region|
  SequenceCounter.find_or_create_by(regime_id: r.id, region: region)
end

r = Regime.find_by!(slug: 'wml')
r.permit_categories.destroy_all
PermitCategoryImporter.import(r, Rails.root.join('db', 'categories', 'waste.csv'))

%w[ A B E N S T U Y ].each do |region|
  SequenceCounter.find_or_create_by(regime_id: r.id, region: region)
end

if User.count.zero?
  u = User.new(first_name: 'Tony',
               last_name: 'Headford',
               email: 'tony@binarycircus.com',
               role: 'admin',
               password: "Ab0#{Devise.friendly_token.first(8)}")
  u.regime_users.build(regime_id: Regime.first.id, enabled: true) 
  u.save!
end
