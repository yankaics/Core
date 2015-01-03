require 'rails_helper'

RSpec.describe Admin, :type => :model do
  its(:devise_modules) { should include(:database_authenticatable, :rememberable, :lockable, :trackable) }
  its(:devise_modules) { should_not include(:registerable) }

  describe 'instantiation' do
    subject!(:admin) { create(:admin) }
    let(:duplicated_admin) { build(:admin, username: admin.username) }

    its(:username) { should be_a_kind_of(String) }

    it "sholud not be valid if having duplicated username" do
      expect(duplicated_admin).not_to be_valid
    end

    it "can't be saved if having duplicated username" do
      expect { duplicated_admin.save! }.to raise_error
    end
  end
end
