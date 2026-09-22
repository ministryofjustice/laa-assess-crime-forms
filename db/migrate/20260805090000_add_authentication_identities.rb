class AddAuthenticationIdentities < ActiveRecord::Migration[8.0]
  def up
    create_table :authentication_identities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false
      t.string :subject, null: false
      t.datetime :first_authenticated_at
      t.datetime :last_authenticated_at
      t.datetime :roles_synced_at
      t.timestamps
    end

    add_index :authentication_identities, %i[provider subject], unique: true
    add_index :authentication_identities, %i[user_id provider], unique: true

    migrate_authentication_identities
  end

  def down
    restore_legacy_authentication_data
    drop_table :authentication_identities
  end

  private

  def migrate_authentication_identities
    execute <<~SQL.squish
      INSERT INTO authentication_identities
        (id, user_id, provider, subject, first_authenticated_at, last_authenticated_at, created_at, updated_at)
      SELECT
        gen_random_uuid(), id, 'azure_ad', auth_subject_id, first_auth_at, last_auth_at,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
      WHERE auth_subject_id IS NOT NULL
    SQL

    execute <<~SQL.squish
      INSERT INTO authentication_identities
        (id, user_id, provider, subject, first_authenticated_at, last_authenticated_at, roles_synced_at,
         created_at, updated_at)
      SELECT
        gen_random_uuid(), id, 'silas', silas_user_name, first_auth_at, last_auth_at,
        silas_roles_last_synced_at, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
      WHERE silas_user_name IS NOT NULL
    SQL
  end

  def restore_legacy_authentication_data
    execute <<~SQL.squish
      UPDATE users
      SET
        auth_subject_id = identities.subject,
        first_auth_at = identities.first_authenticated_at,
        last_auth_at = identities.last_authenticated_at
      FROM authentication_identities identities
      WHERE identities.user_id = users.id AND identities.provider = 'azure_ad'
    SQL

    execute <<~SQL.squish
      UPDATE users
      SET
        silas_user_name = identities.subject,
        silas_roles_last_synced_at = identities.roles_synced_at
      FROM authentication_identities identities
      WHERE identities.user_id = users.id AND identities.provider = 'silas'
    SQL
  end
end
