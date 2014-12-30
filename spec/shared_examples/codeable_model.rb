require 'rails_helper'

RSpec.shared_examples "a codeable model" do
  let(:thing) { build(described_class) }

  it "validates format of code" do
    thing.code = '安安 你好'
    expect(thing).not_to be_valid
  end

  it "has friendly ID 'code'" do
    thing.save!
    expect(described_class.friendly.find(thing.code)).to eq thing
  end
end
