require 'rails_helper'

describe MemberReward do
  it 'has a valid factory' do
    FactoryGirl.build(:member_reward).should be_valid
  end
  it 'requires a member' do
    FactoryGirl.build(:member_reward, member: nil).should_not be_valid
  end
  it 'requires a reward' do
    FactoryGirl.build(:member_reward, reward: nil).should_not be_valid
  end
  it 'require redeemed to be false if not true' do
    FactoryGirl.build(:member_reward, redeemed: 5).redeemed.should be_false
    FactoryGirl.build(:member_reward, redeemed: 'a').redeemed.should be_false
    FactoryGirl.build(:member_reward, redeemed: 1).should be_valid
    FactoryGirl.build(:member_reward, redeemed: 0).should be_valid
    FactoryGirl.build(:member_reward, redeemed: nil).redeemed.should be_false
  end
end
