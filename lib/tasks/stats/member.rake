namespace :stats do
  namespace :member do
    # {{{ desc "Member: Generate stats for a member"
    desc "Member: Generate stats for a member"
    task :generate, [:email] => %w[points rewards stores surveys] do |t, args|
    end

    # }}}
  end
end
