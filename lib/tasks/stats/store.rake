namespace :stats do 
  namespace :store do
    # {{{ desc "Store: Generate stats for a store"
    desc "Store: Generate stats for a store"
    multitask :generate, [:key] => %w{surveys members} do |t, args|
    end
    
    # }}}
  end
end
