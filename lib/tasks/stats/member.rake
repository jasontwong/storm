namespace :stats do
  namespace :member do
    # {{{ desc "Generate all stats for a member"
    desc "Generate all stats for a member"
    task :generate, [:email] => %w[points:available points:earned rewards:available rewards:redeemed stores:unique_visits stores:visits surveys:submitted] do |t, args|
    end

    # }}}
  end
end
