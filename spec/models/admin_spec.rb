require 'rails_helper'

RSpec.describe Admin, :type => :model do
  its(:devise_modules) { should include(:database_authenticatable, :rememberable, :lockable, :trackable) }
  its(:devise_modules) { should_not include(:registerable) }

  describe "instantiation" do
    subject!(:admin) { create(:admin) }
    let(:duplicated_admin) { build(:admin, username: admin.username) }

    its(:username) { should be_a_kind_of(String) }

    it "sholud not be valid if having duplicated username" do
      expect(duplicated_admin).not_to be_valid
    end

    it "can't be saved if having duplicated username" do
      expect { duplicated_admin.save! }.to raise_error
    end

    context "root" do
      subject!(:admin) { create(:admin) }

      it { is_expected.to be_root }
      it { is_expected.not_to be_scoped }
    end

    context "scoped" do
      subject!(:admin) { create(:admin, scoped_organization_code: 'CODE') }

      it { is_expected.not_to be_root }
      it { is_expected.to be_scoped }
    end
  end

  describe "#admins" do
    it "returns an associative array containing exactly itself" do
      admin = create(:admin)
      expect(admin.admins).to be_a(ActiveRecord::Relation)
      expect(admin.admins).to contain_exactly(admin)
    end
  end
end
