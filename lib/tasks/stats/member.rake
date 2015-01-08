namespace :stats do
  namespace :member do
    # {{{ desc "Member: Generate stats for a member"
    desc "Member: Generate stats for a member"
    multitask :generate, [:member] => %w[points rewards stores surveys] do |t, args|
    end

    # }}}
  end
end
