require "rails_helper"

describe "Open Data API" do
  let(:data_api) do
    create(:data_api, :with_data, data_count: 32, path: 'path/to/data_api',
                                  schema: { string_col: { type: 'string' },
                                            integer_col: { type: 'integer' } })
  end
  let(:another_data_api) do
    create(:data_api, :with_data, data_count: 10, path: 'path/to/another_data_api',
                                  primary_key: :integer_col,
                                  schema: { string_col: { type: 'string' },
                                            integer_col: { type: 'integer' },
                                            float_col: { type: 'float' },
                                            boolean_col: { type: 'boolean' },
                                            text_col: { type: 'text' },
                                            datetime_col: { type: 'datetime' } })
  end

  describe "resource collection" do
    it "returns datas" do
      get "/api/#{data_api.path}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      last_data = data_api.data_model.last
      expect(json).to include({ 'id' => last_data.id, 'string_col' => last_data.string_col, 'integer_col' => last_data.integer_col, 'type' => data_api.name.classify })
    end

    it "is fieldsettable" do
      last_data = another_data_api.data_model.last
      get "/api/#{another_data_api.path}.json?fields=string_col,integer_col"
      expect(response).to be_success
      expect(response.body).to include(last_data.string_col)
      expect(response.body).to include("#{last_data.integer_col}")
      expect(response.body).not_to include(last_data.text_col)

      get "/api/#{another_data_api.path}.json?fields=text_col"
      expect(response).to be_success
      expect(response.body).not_to include(last_data.string_col)
      expect(response.body).to include(last_data.text_col)
    end
  end

  describe "single resource" do
    it "returns a data" do
      first_data = data_api.data_model.first
      get "/api/#{data_api.path}/#{first_data.id}.json"
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json).to eq({ 'id' => first_data.id, 'string_col' => first_data.string_col, 'integer_col' => first_data.integer_col, 'type' => data_api.name.classify })

      second_data = another_data_api.data_model.second
      get "/api/#{another_data_api.path}/#{second_data.integer_col}.json"
      expect(response).to be_success
      expect(response.body).to include(second_data.text_col)
    end

    it "is fieldsettable" do
      last_data = another_data_api.data_model.last
      get "/api/#{another_data_api.path}/#{last_data.integer_col}.json?fields=string_col,integer_col"
      expect(response).to be_success
      expect(response.body).to include(last_data.string_col)
      expect(response.body).to include("#{last_data.integer_col}")
      expect(response.body).not_to include(last_data.text_col)

      get "/api/#{another_data_api.path}/#{last_data.integer_col}.json?fields=text_col"
      expect(response).to be_success
      expect(response.body).not_to include(last_data.string_col)
      expect(response.body).to include(last_data.text_col)
    end
  end
end
