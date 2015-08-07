require 'rails_helper'

RSpec.describe ServiceNavigation, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:order) }
  it { should validate_presence_of(:index_order) }
  it { should validate_presence_of(:index_size) }
end
