require 'rails_helper'

RSpec.shared_examples "a serializable model" do
  let(:thing) { build(described_class) }

  describe ".serialize_it" do
    it "returns the serialized model" do
      expect(described_class.all.serialize_it).to be_a_kind_of(ActiveModel::ArraySerializer)
    end
  end

  describe "#serialize_it" do
    it "returns the serialized instance" do
      expect(thing.serialize_it).to be_a_kind_of(ActiveModel::Serializer)
    end
  end

  describe ".serialized_object" do
    it "returns the serialized model as an Array" do
      expect(described_class.all.serialized_object).to be_a_kind_of(Array)
      expect(described_class.all.serialized_object).to eq described_class.all.serialize_it.as_json
    end
  end

  describe "#serialized_object" do
    it "returns the serialized instance as a Hash" do
      expect(thing.serialized_object).to be_a_kind_of(Hash)
      expect(thing.serialized_object).to eq thing.serialize_it.as_json
    end
  end
end
