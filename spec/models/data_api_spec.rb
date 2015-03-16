require 'rails_helper'

RSpec.describe DataAPI, type: :model do
  it { should belong_to(:organization) }
  it { should serialize(:schema) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:path) }

  describe "DataAPI #data_model" do
    subject(:model) { create(:data_api).data_model }

    it "should require uid to be set" do
      expect(model.new(uid: nil)).not_to be_valid
      expect(model.new(uid: 'val')).to be_valid
    end

    it "should require unique value for uid" do
      model.create(uid: 'val')
      expect(model.new(uid: 'val')).not_to be_valid
      expect(model.new(uid: 'other_val')).to be_valid
    end
  end

  with_versioning do
    let!(:data_api) do
      create(:data_api, schema: { string_attr: { type: 'string' },
                                  text_attr: { type: 'text' },
                                  datetime_attr: { type: 'datetime' },
                                  boolean_attr: { type: 'boolean' } } )
    end

    context "on create" do
      it "creates the corresponding database table" do
        model = data_api.data_model
        expect(model.inspect).to include('string_attr: string')
        expect(model.inspect).to include('datetime_attr: datetime')
        expect(model.inspect).to include('boolean_attr: boolean')
        expect(model.inspect).to include('text_attr: text')
      end
    end

    context "on renamed" do
      it "renames the corresponding database table" do
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.table_name).to eq(data_api.name)

        data_api.name = 'hello_api'
        data_api.save
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.table_name).to eq('hello_api')

        data_api.update(name: 'hello_world')
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.table_name).to eq('hello_world')
      end
    end

    context "on schema changed" do
      it "renames the renamed column in database" do
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.inspect).to include('text_attr: text')
        data_api.schema[:hi_string] = data_api.schema[:string_attr]
        data_api.schema[:string_attr] = nil
        data_api.schema[:hi_text] = data_api.schema[:text_attr]
        data_api.schema[:text_attr] = nil
        data_api.save
        expect(data_api.data_model.inspect).to include('hi_string: string')
        expect(data_api.data_model.inspect).to include('hi_text: text')
      end

      it "removes the removed column in database" do
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.inspect).to include('text_attr: text')
        data_api.schema[:string_attr] = nil
        data_api.schema[:text_attr] = nil
        data_api.save
        expect(data_api.data_model.inspect).not_to include('string_attr: string')
        expect(data_api.data_model.inspect).not_to include('text_attr: text')
      end

      it "adds the added column in database" do
        data_api.schema[:new_string_attr] = { type: 'string' }
        data_api.schema[:new_text_attr] = { type: 'text' }
        data_api.save
        expect(data_api.data_model.inspect).to include('new_string_attr: string')
        expect(data_api.data_model.inspect).to include('new_text_attr: text')
      end
    end

    context "on destroy" do
      it "drops the corresponding database table" do
        model = data_api.data_model
        model.all

        data_api.destroy
        expect(model.inspect).to include("Table doesn't exist")
      end
    end
  end
end
