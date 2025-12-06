# frozen_string_literal: true

class CreateDiscourseSaasTables < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_saas_license_packages do |t|
      t.string :name, null: false
      t.integer :price, null: false
      t.integer :duration_days, null: false
      t.integer :seats, default: 1
      t.integer :group_id, null: false
      t.boolean :is_org_license, default: false
      t.timestamps
    end

    create_table :discourse_saas_purchases do |t|
      t.integer :user_id, null: false
      t.integer :license_package_id, null: false
      t.string :external_id, null: false
      t.datetime :purchased_at, null: false
      t.datetime :expires_at, null: false
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :discourse_saas_purchases, :external_id, unique: true
    add_index :discourse_saas_purchases, :expires_at

    create_table :discourse_saas_organisations do |t|
      t.string :name, null: false
      t.integer :owner_id, null: false
      t.integer :purchase_id, null: false
      t.integer :group_id
      t.integer :seats_total, default: 0
      t.integer :seats_used, default: 0
      t.boolean :active, default: true
      t.timestamps
    end

    create_table :discourse_saas_organisation_members do |t|
      t.integer :organisation_id, null: false
      t.integer :user_id, null: false
      t.boolean :owner, default: false
      t.boolean :seated, default: false
      t.timestamps
    end

    add_index :discourse_saas_organisation_members,
              [:organisation_id, :user_id],
              unique: true,
              name: "idx_saas_org_members_org_user"
  end
end
