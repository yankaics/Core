require 'rails_helper'

RSpec.describe DataAPI::Schema do
  it { is_expected.to be_a(Hash) }
  it { is_expected.to be_a(HashWithIndifferentAccess) }

  describe "initialization" do
    context "as a string" do
      subject { DataAPI::Schema.new('{"col_name":{"uuid":"5361e73c-b17b-4cb7-9a75-800c149a813a","type":"string"}}') }

      it "tries to parse the string as JSON" do
        expect(subject[:col_name]).to be_a(Hash)
      end
    end

    context "as a hash" do
      subject { DataAPI::Schema.new({ col_name: { uuid: "5361e73c-b17b-4cb7-9a75-800c149a813a", type: "string" } }) }

      it "will be constructed" do
        expect(subject['col_name']).to be_a(Hash)
      end
    end

    it "clears unknown column attributes" do
      schema = DataAPI::Schema.new({
        col_name: { uuid: "5361e73c-b17b-4cb7-9a75-800c149a813a",
                    type: "string",
                    unknown_attr: "?" }
      })
      expect(schema[:col_name]).not_to have_key(:unknown_attr)
      expect(schema[:col_name]).to     have_key(:type)
    end

    it "clears invalid column attributes" do
      schema = DataAPI::Schema.new({
        col_name: { uuid: "5361e73c-b17b-4cb7-9a75-800c149a813a",
                    index: 'wrong type' }
      })
      expect(schema[:col_name]).not_to have_key(:index)

      schema = DataAPI::Schema.new({
        col_name: { uuid: "5361e73c-b17b-4cb7-9a75-800c149a813a",
                    index: true }
      })
      expect(schema[:col_name]).to have_key(:index)
    end

    it "generates uuid for new columns" do
      schema = DataAPI::Schema.new({
        old_col: { uuid: "5361e73c-b17b-4cb7-9a75-800c149a813a",
                   type: "string" },
        new_col: { uuid: "",
                   type: "integer" }
      })
      expect(schema[:new_col][:uuid]).not_to be_blank
      expect(schema[:old_col][:uuid]).to     eq('5361e73c-b17b-4cb7-9a75-800c149a813a')
    end

    it "set default type for columns" do
      schema = DataAPI::Schema.new({
        col1: { type: "integer" },
        col2: { type: "bla" },
        col3: { type: "" }
      })
      expect(schema[:col1][:type]).to eq('integer')
      expect(schema[:col2][:type]).to eq('string')
      expect(schema[:col3][:type]).to eq('string')
    end
  end

  describe "#load_from_array" do
    subject(:schema) do
      schema = DataAPI::Schema.new({ old_col: { type: 'string' } })
    end

    it "loads the schema from an array" do
      subject.load_from_array([
        { name: 'col1', type: 'text' },
        { name: 'col2', type: 'string' },
        { name: 'col3', type: 'integer', index: true }
      ])

      expect(subject).not_to have_key(:old_col)
      expect(subject[:col1][:type]).to eq('text')
      expect(subject[:col2][:type]).to eq('string')
      expect(subject[:col3][:type]).to eq('integer')
      expect(subject[:col3][:index]).to be(true)
    end
  end

  describe "#validate!" do
    subject(:schema) do
      schema = DataAPI::Schema.new
      schema[:empty_col] = {}
      schema[:invalid_col] = 'hi'
      schema[:col] = {
        uuid: 'temp-uuid',
        type: 'wrong_val',
        index: 'wrong_type',
        unknown_attr: '',
      }
      schema[:col2] = {
        uuid: '5361e73c-b17b-4cb7-9a75-800c149a813a'
      }
      schema[:id] = {
        uuid: '0233fe82-2ba4-4992-85b3-4d5f0d231d56'
      }
      schema[:dup_uuid] = {
        uuid: '0b2e1330-58f1-42cf-b292-e6161473931e'
      }
      schema[:dup_uuid2] = {
        uuid: '0b2e1330-58f1-42cf-b292-e6161473931e'
      }
      schema[:new_dup_uuid] = {
        uuid: '0b2e1330-58f1-42cf-b292-e6161473931e'
      }
      schema
    end

    it "removes empty columns" do
      subject.validate!
      expect(subject).not_to have_key(:empty_col)
    end

    it "removes invalid columns" do
      subject.validate!
      expect(subject).not_to have_key(:invalid_col)
      expect(subject).not_to have_key(:id)
    end

    it "generates uuid for new columns" do
      subject.validate!
      expect(subject[:col][:uuid]).not_to eq('temp-uuid')
      expect(subject[:col2][:uuid]).to eq('5361e73c-b17b-4cb7-9a75-800c149a813a')
    end

    it "sets default column type" do
      subject.validate!
      expect(subject[:col][:type]).to eq('string')
    end

    it "removes invalid column attributes" do
      subject.validate!
      expect(subject[:col]).not_to have_key(:index)
    end

    it "removes unknown column attributes" do
      subject.validate!
      expect(subject[:col]).not_to have_key(:unknown_attr)
    end

    it "removes old columns with duplicated uuid" do
      subject.validate!
      expect(subject).not_to have_key(:dup_uuid)
      expect(subject).not_to have_key(:dup_uuid_2)
      expect(subject).to have_key(:new_dup_uuid)
    end
  end

  describe "#to_s" do
    let(:schema) { DataAPI::Schema.new({ col: { type: '' } }) }

    it "returns a JSON string" do
      expect(schema.to_s).to eq(schema.to_json)
    end
  end

  describe "#to_hash_indexed_with_uuid" do
    let(:schema) do
      DataAPI::Schema.new({
        col: { uuid: '5361e73c-b17b-4cb7-9a75-800c149a813a' },
        col2: { uuid: '0233fe82-2ba4-4992-85b3-4d5f0d231d56' }
      })
    end
    subject { schema.to_hash_indexed_with_uuid }

    it "returns a hash indexed with uuid" do
      expect(subject).to be_a(HashWithIndifferentAccess)
      expect(subject['5361e73c-b17b-4cb7-9a75-800c149a813a']).to be_a(Hash)
      expect(subject['5361e73c-b17b-4cb7-9a75-800c149a813a'][:name]).to eq('col')
      expect(subject['0233fe82-2ba4-4992-85b3-4d5f0d231d56']).to be_a(Hash)
      expect(subject['0233fe82-2ba4-4992-85b3-4d5f0d231d56'][:name]).to eq('col2')
    end
  end
end
