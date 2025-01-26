class CreateDecidimTranslationAddonsReportDetail < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_translation_addons_report_details do |t|
      t.references :decidim_user, null: false, index: { name: "index_decidim_t_a_r_d_on_decidim_user_id" }
      t.references :decidim_translation_addons_report, null: false, index: { name: "index_decidim_t_a_r_d_on_report_id" }
      t.string :reason
      t.string :fix_suggestion

      t.timestamps
    end
  end
end
