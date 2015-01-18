class CreateDoorkeeperTables < ActiveRecord::Migration
  def change
    create_table :oauth_applications do |t|
      t.string   :name,         null: false
      t.text     :description
      t.string   :app_url
      t.integer  :owner_id,     null: false
      t.string   :owner_type,   null: false
      t.string   :uid,          null: false
      t.string   :secret,       null: false
      t.text     :redirect_uri, null: false
      t.string   :scopes,       null: false, default: ''
      t.text     :extensional_scopes
      t.text     :data
      t.boolean  :blocked,      null: false, default: false
      t.integer  :sms_quota,    null: false, default: 0
      t.integer  :rth,          null: false, default: 0
      t.datetime :rth_refreshed_at
      t.integer  :rtd,          null: false, default: 0
      t.date     :rtd_refreshed_at
      t.integer  :core_rth,     null: false, default: 0
      t.datetime :core_rth_refreshed_at
      t.integer  :core_rtd,     null: false, default: 0
      t.date     :core_rtd_refreshed_at
      t.timestamps
    end

    add_index  :oauth_applications, :uid, unique: true
    add_index  :oauth_applications, [:owner_id, :owner_type]

    create_table :oauth_access_grants do |t|
      t.integer  :resource_owner_id, null: false
      t.integer  :application_id,    null: false
      t.string   :token,             null: false
      t.integer  :expires_in,        null: false
      t.text     :redirect_uri,      null: false
      t.datetime :created_at,        null: false
      t.datetime :revoked_at
      t.string   :scopes
    end

    add_index :oauth_access_grants, :token, unique: true

    create_table :oauth_access_tokens do |t|
      t.integer  :resource_owner_id
      t.integer  :application_id
      t.string   :token,             null: false
      t.string   :refresh_token
      t.integer  :expires_in
      t.datetime :revoked_at
      t.datetime :created_at,        null: false
      t.string   :scopes
    end

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :resource_owner_id
    add_index :oauth_access_tokens, :refresh_token, unique: true
  end
end
