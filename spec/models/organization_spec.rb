require 'rails_helper'

RSpec.describe Organization, :type => :model do
  it_should_behave_like "a codeable model"

  xit { should have_many(:users) }
  xit { should have_many(:departments) }
  xit { should have_many(:email_patterns) }

  xit { should accept_nested_attributes_for(:departments) }
  xit { should accept_nested_attributes_for(:email_patterns) }

  it { should validate_uniqueness_of(:code) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }
end
