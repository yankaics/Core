require 'rails_helper'

RSpec.describe DataAPI, type: :model do
  it { should belong_to(:organization) }
  it { should serialize(:schema) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:path) }
end
