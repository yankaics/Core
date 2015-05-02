require 'rails_helper'

RSpec.describe DataAPI, type: :model do
  after(:all) do
    test_api_mt_db = Rails.root.join('db', 'test_api_mt.sqlite3')
    File.delete(test_api_mt_db) if File.exist?(test_api_mt_db)
  end

  it { should belong_to(:organization) }
  it { should serialize(:schema) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:path) }

  describe "instance" do
    subject(:data_api) { create(:data_api) }

    its(:schema) { is_expected.to be_a(Hash) }
  end

  describe ".find_by_path" do
    let!(:a_api) { create(:data_api, path: 'path/to/a/api') }
    let!(:another_api) { create(:data_api, path: 'path/to/another/api') }

    it "returns matching data_api by a resource collection path" do
      data_api = DataAPI.find_by_path('path/to/a/api')
      expect(data_api).to eq(a_api)
      expect(data_api.single_data_id).to be_blank
      data_api = DataAPI.find_by_path('path/to/another/api')
      expect(data_api).to eq(another_api)
      expect(data_api.single_data_id).to be_blank
    end

    it "returns matching data_api containing single_data_id by a single resource path" do
      data_api = DataAPI.find_by_path('path/to/a/api/some_id')
      expect(data_api).to eq(a_api)
      expect(data_api.single_data_id).to eq('some_id')
      data_api = DataAPI.find_by_path('path/to/another/api/yet_another_id')
      expect(data_api).to eq(another_api)
      expect(data_api.single_data_id).to eq('yet_another_id')
    end
  end

  describe "DataAPI #data_model" do
    subject(:model) { create(:data_api).data_model }

    # it "should require uid to be set" do
    #   expect(model.new(uid: nil)).not_to be_valid
    #   expect(model.new(uid: 'val')).to be_valid
    # end

    # it "should require unique value for uid" do
    #   model.create(uid: 'val')
    #   expect(model.new(uid: 'val')).not_to be_valid
    #   expect(model.new(uid: 'other_val')).to be_valid
    # end
  end

  context "with invalid attributes" do
    it "should not be valid if name starts with a number" do
      data_api = build(:data_api, name: '0abcd')
      expect(data_api).not_to be_valid
    end

    it "should not be valid if name contains special characters" do
      data_api = build(:data_api, name: 'OK_好！')
      expect(data_api).not_to be_valid
    end

    it "should not be valid if path contains special characters" do
      data_api = build(:data_api, path: 'a_b_c_d')
      expect(data_api).to be_valid
      data_api = build(:data_api, path: 'a/b')
      expect(data_api).to be_valid
      data_api = build(:data_api, path: 'a/b/c')
      expect(data_api).to be_valid
      data_api = build(:data_api, path: 'a/b/c/d/e/f/g/h')
      expect(data_api).not_to be_valid
      data_api = build(:data_api, path: 'A/B')
      expect(data_api).not_to be_valid
    end

    it "should not be valid if schema column has duplicated uuid" do
      data_api = build(:data_api, schema: { attr1: { type: 'string', uuid: '86f05e6d-7fac-4837-a424-a883b90b2a94' }, attr2: { type: 'text', uuid: '86f05e6d-7fac-4837-a424-a883b90b2a94' } })
      expect(data_api).not_to be_valid
    end

    it "should not be valid if schema column has invalid type" do
      data_api = build(:data_api, schema: { attr1: { type: 'foo', uuid: '86f05e6d-7fac-4837-a424-a883b90b2a94' } })
      expect(data_api).not_to be_valid
    end

    it "should not be valid if schema column used a reserved name" do
      data_api = build(:data_api, schema: { id: { type: 'string' } })
      expect(data_api).not_to be_valid
    end

    it "should not be valid if type of existing schema column has changed" do
      data_api = create(:data_api, schema: { attr1: { type: 'string' }, attr2: { type: 'text' } })
      expect(data_api).to be_valid
      data_api.schema['attr2']['type'] = 'string'
      expect(data_api).not_to be_valid
    end

    it "should not be valid if maintain_schema turned off while using system database" do
      data_api = create(:data_api, schema: { attr1: { type: 'string' }, attr2: { type: 'text' } })
      expect(data_api).to be_valid
      data_api.maintain_schema = false
      expect(data_api).not_to be_valid
      data_api.database_url = 'sqlite3:db/test_api_test.sqlite3'
      expect(data_api).to be_valid
    end

    it "should not be valid if having invalid database_url" do
      data_api = create(:data_api, schema: { attr1: { type: 'string' }, attr2: { type: 'text' } })
      expect(data_api).to be_valid
      data_api.database_url = 'sqlite3://tmp/'
      expect(data_api).not_to be_valid
      data_api.database_url = 'sqlite3:db/test_api_mt.sqlite3'
      expect(data_api).to be_valid
      data_api.database_url = 'http://colorgy.dev'
      expect(data_api).not_to be_valid
      data_api.database_url = 'postgresql://USER:PASSWORD@HOST:PORT/NAME'
      expect(data_api).to be_valid
      data_api.database_url = 'mysql://USER:PASSWORD@HOST:PORT/NAME'
      expect(data_api).to be_valid
    end
  end

  with_versioning do
    let(:data_api) do
      create(:data_api, schema: { string_attr: { type: 'string' },
                                  text_attr: { type: 'text' },
                                  datetime_attr: { type: 'datetime' },
                                  boolean_attr: { type: 'boolean' } })
    end
    let(:outer_data_api) { create(:data_api, :with_data, database_url: 'sqlite3:db/test_api_mt.sqlite3') }

    context "on create" do
      it "creates the corresponding database table" do
        model = data_api.data_model
        model.connection
        expect(model.inspect).to include('string_attr: string')
        expect(model.inspect).to include('datetime_attr: datetime')
        expect(model.inspect).to include('boolean_attr: boolean')
        expect(model.inspect).to include('text_attr: text')
      end

      context "using outer database with maintain_schema off" do
        it "does not create the outer database schema" do
          new_outer_data_api = build(:data_api, maintain_schema: false, database_url: 'sqlite3:db/test_api_mt.sqlite3')
          new_outer_data_api.save!
          new_outer_data_api.data_model.connection
          expect(new_outer_data_api.data_model.inspect).not_to include('string')
          expect { new_outer_data_api.data_model.last }.to raise_error
        end
      end
    end

    context "on renamed" do
      it "renames the corresponding database table" do
        data_api.data_model.connection
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.table_name).to eq(data_api.name)

        data_api.name = 'hello_api'
        data_api.save
        data_api.data_model.connection
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.table_name).to eq('hello_api')

        data_api.update(name: 'hello_world')
        data_api.data_model.connection
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.table_name).to eq('hello_world')
      end
    end

    context "on schema changed" do
      it "renames the renamed column in database" do
        data_api.data_model.connection
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.inspect).to include('text_attr: text')
        data_api.schema['hi_string'] = data_api.schema['string_attr']
        data_api.schema['string_attr'] = nil
        data_api.schema['hi_text'] = data_api.schema['text_attr']
        data_api.schema['text_attr'] = nil
        data_api.save
        data_api.data_model.connection
        expect(data_api.data_model.inspect).to include('hi_string: string')
        expect(data_api.data_model.inspect).to include('hi_text: text')
      end

      it "removes the removed column in database" do
        data_api.data_model.connection
        expect(data_api.data_model.inspect).to include('string_attr: string')
        expect(data_api.data_model.inspect).to include('text_attr: text')
        data_api.schema['string_attr'] = nil
        data_api.schema['text_attr'] = nil
        data_api.save
        data_api.data_model.connection
        expect(data_api.data_model.inspect).not_to include('string_attr: string')
        expect(data_api.data_model.inspect).not_to include('text_attr: text')
      end

      it "adds the added column in database" do
        data_api.schema['new_string_attr'] = { type: 'string' }
        data_api.schema['new_text_attr'] = { type: 'text' }
        data_api.save
        data_api.data_model.connection
        expect(data_api.data_model.inspect).to include('new_string_attr: string')
        expect(data_api.data_model.inspect).to include('new_text_attr: text')
      end

      context "using outer database with maintain_schema off" do
        it "does not change the outer database schema" do
          outer_data_api.maintain_schema = false
          outer_data_api.schema['new_string_attr'] = { type: 'string' }
          outer_data_api.save!
          outer_data_api.data_model.connection
          expect(outer_data_api.data_model.inspect).not_to include('new_string_attr')
          sample_data = outer_data_api.data_model.first
          expect { sample_data.new_string_attr }.to raise_error
        end
      end
    end

    context "on destroy" do
      it "drops the corresponding database table" do
        model = data_api.data_model
        model.all

        data_api.destroy
        model.connection
        expect(model.inspect).to include("Table doesn't exist")
      end
    end

    describe "#schema_from_array" do
      it "loads the schema from an array" do
        array = [{ name: 'string', type: 'string' }, { name: 'text', type: 'text' }]
        data_api.schema_from_array(array)

        expect(data_api.schema['string']).to eq({ 'type' => 'string' })
        expect(data_api.schema['text']).to eq({ 'type' => 'text' })

        data_api.save!

        expect(data_api.schema).to have_key('string')
        expect(data_api.schema).to have_key('text')
      end
    end
  end
end
