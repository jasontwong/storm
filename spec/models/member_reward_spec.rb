require 'rails_helper'

describe MemberReward do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:member_reward)).to be_valid
  end
  it 'requires a member' do
    expect(FactoryGirl.build(:member_reward, member: nil)).not_to be_valid
  end
  it 'requires a reward' do
    expect(FactoryGirl.build(:member_reward, reward: nil)).not_to be_valid
  end
  it 'require redeemed to be false if not true' do
    expect(FactoryGirl.build(:member_reward, redeemed: 5).redeemed).to be_false
    expect(FactoryGirl.build(:member_reward, redeemed: 'a').redeemed).to be_false
    expect(FactoryGirl.build(:member_reward, redeemed: 1)).to be_valid
    expect(FactoryGirl.build(:member_reward, redeemed: 0)).to be_valid
    expect(FactoryGirl.build(:member_reward, redeemed: nil).redeemed).to be_false
  end
end
