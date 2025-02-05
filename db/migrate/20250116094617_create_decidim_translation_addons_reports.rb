# frozen_string_literal: true

class CreateDecidimTranslationAddonsReports < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_translation_addons_reports do |t|
      t.references :decidim_resource, polymorphic: true, index: false, null: false
      t.string :field_name
      t.string :locale
      t.integer :auto_translation_retry_count, default: 0
      t.datetime :translation_last_retry_on
      t.timestamps
    end
    add_index :decidim_translation_addons_reports, [:decidim_resource_type, :decidim_resource_id], name: "index_decidim_t_a_reports_on_resource"
  end
end
