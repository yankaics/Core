require 'rails_helper'

RSpec.shared_examples "a codeable model" do
  let(:thing) { build(described_class) }

  it "validates format of code" do
    thing.code = '安安 你好'
    expect(thing).not_to be_valid
  end
end
