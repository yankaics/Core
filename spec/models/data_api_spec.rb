require 'rails_helper'

RSpec.describe DataAPI, type: :model do
  after(:all) do
    test_api_mt_db = Rails.root.join('db', 'test_api_mt.sqlite3')
    File.delete(test_api_mt_db) if File.exist?(test_api_mt_db)
  end

  it { should belong_to(:organization) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:path) }

  describe "instance" do
    subject(:data_api) { create(:data_api) }

    its(:schema) { is_expected.to be_a(DataAPI::Schema) }
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

    context "owned by user" do
      let(:user) do
        create(:user, :confirmed, :with_identity)
      end
      let(:user2) do
        create(:user, :confirmed, :with_identity)
      end
      let(:data_api_owned_by_user) do
        data_api = create(:data_api, path: 'path/to/data_api_owned_by_user',
                                     organization_code: user.organization_code,
                                     owned_by_user: true,
                                     owner_primary_key: 'id',
                                     owner_foreign_key: 'user_id',
                                     schema: { user_id: { type: 'string' },
                                               user_uuid: { type: 'string' },
                                               user_email: { type: 'string' },
                                               user_uid: { type: 'string' } })
        data_api.data_model.create!(user_id: user.id, user_uuid: user.uuid, user_email: user.email, user_uid: user.uid)
        data_api.data_model.create!(user_id: user2.id, user_uuid: user2.uuid, user_email: user2.email, user_uid: user2.uid)
        data_api
      end
      subject(:model) { data_api_owned_by_user.data_model }

      it "should belong to owner" do
        expect(model.first.owner).to eq(user)
        expect(model.last.owner).to eq(user2)
      end

      it "should belong to owner through uuid" do
        data_api_owned_by_user.owner_primary_key = 'uid'
        data_api_owned_by_user.owner_foreign_key = 'user_uid'
        data_api_owned_by_user.save!
        model = data_api_owned_by_user.data_model

        expect(model.first.owner).to eq(user)
        expect(model.last.owner).not_to eq(user2)
      end
    end
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

    it "should not be valid if owned by user but has invalid owner_primary_key or owner_foreign_key" do
      data_api = create(:data_api, schema: { attr1: { type: 'string' }, attr2: { type: 'text' } })
      data_api.owned_by_user = true
      expect(data_api).not_to be_valid
      data_api.owner_primary_key = 'uuid'
      data_api.owner_foreign_key = 'attr1'
      expect(data_api).to be_valid
      data_api.owner_primary_key = 'uuid'
      data_api.owner_foreign_key = 'invalid_attr'
      expect(data_api).not_to be_valid
      data_api.owner_primary_key = 'invalid_attr'
      data_api.owner_foreign_key = 'attr1'
      expect(data_api).not_to be_valid
    end
  end

  describe "database maintenance" do
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
  end
end
