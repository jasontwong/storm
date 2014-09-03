namespace :migration do
  desc "Migrate company level points/rewards to store level"
  task :migrate_points_rewards => :environment do
    Company.all.each do |comp|
      group = StoreGroup.create!(name: comp.name)
      comp.stores.each do |store|
        store.store_group = group
        store.save
      end
    end
    
  end

end
