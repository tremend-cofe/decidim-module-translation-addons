# frozen_string_literal: true

namespace :decidim do
  namespace :translation_addons do
    # task upgrade: [:choose_target_plugins, :"railties:install:migrations"]

    task :choose_target_plugins do
      ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_translation_addons"
    end

    desc "Searches for missing translations and adds reports"
    task search_missing_translations: :environment do
      def merge_machine_translations_without_override(original)
        # Extract the machine translations
        machine_translations = original["machine_translations"] || {}
        # Merge machine translations into the original hash with conditional logic for key collisions
        merged = original.merge(machine_translations) do |_key, main_val, _machine_val|
          main_val # Keep the value from the main object when keys collide
        end
        # Remove the "machine_translations" key and empty keys from the result
        merged.except("machine_translations").reject { |_, value| value.nil? || value == "" }
      end

      reportable_classes_list = Decidim::TranslationAddons.reportable_resources.select do |klass|
        klass.safe_constantize.present?
      end

      organizations = Decidim::Organization.all
      admin_user = Decidim::User.find 1

      reportable_classes_list.each do |klass|
        klass = klass.safe_constantize
        fields = klass.translatable_fields_list
        soft_deletable = klass.column_names.include?("deleted_at")
        resources = soft_deletable ? klass.where(deleted_at: nil) : klass.all

        # Create data object with all info so we don't have to query later
        missing_details = Decidim::TranslationAddons::ReportDetail.includes(:report).where(reason: "missing",
                                                                                           report: { decidim_resource_type: klass.name }).each_with_object({}) do |detail, hash|
          resource_id = detail.report.decidim_resource_id
          field_name = detail.report.field_name
          locale = detail.report.locale
          hash[resource_id.to_s] ||= {}
          hash[resource_id.to_s][field_name] ||= {}
          hash[resource_id.to_s][field_name][locale] ||= {
            "report_by_admin" => false,
            "report_id" => detail.report.id,
            "detail_list" => []
          }
          raise "Something went wrong" if hash[resource_id.to_s][field_name][locale]["report_id"] != detail.report.id

          hash[resource_id.to_s][field_name][locale]["report_by_admin"] = detail.decidim_user_id == admin_user.id
          hash[resource_id.to_s][field_name][locale]["detail_list"].push(detail.id)
        end
        organizations.each do |org|
          available_locales = org.available_locales
          resources.each do |resource|
            next if resource.organization.id != org.id

            fields.each do |field|
              next if resource[field].blank?

              translations = merge_machine_translations_without_override resource[field]
              translations_keys = translations.keys
              missing = available_locales - translations_keys
              not_missing = available_locales & translations_keys
              if missing.present?

                missing.each do |locale|
                  if missing_details.dig(resource.id.to_s, field.to_s, locale.to_s, "report_by_admin") == true
                    puts "Report already exists: #{resource.class.name}, id: #{resource.id}, field: #{field}, locale: #{locale}"
                  else
                    puts "Creating report class: #{resource.class.name}, id: #{resource.id}, field: #{field}, locale: #{locale}"
                    ActiveRecord::Base.transaction do
                      # Get report id from data object
                      report_id = missing_details.dig(resource.id.to_s, field.to_s, locale.to_s, "report_id")
                      if report_id.blank?
                        report = Decidim::TranslationAddons::Report.new(
                          decidim_resource_type: resource.class.name,
                          decidim_resource_id: resource.id,
                          reason: "missing",
                          field_name: field,
                          locale:
                        )
                        report.save!
                        report_id = report.id
                      end

                      if report_id.present?
                        detail = Decidim::TranslationAddons::ReportDetail.new(
                          decidim_user_id: admin_user.id,
                          decidim_translation_addons_report_id: report_id,
                          reason: "missing"
                        )
                        detail.save!
                      end
                    rescue StandardError => e
                      puts "Failed to save report class: #{resource.class.name}, id: #{resource.id}, field: #{field}, locale: #{locale}, message: #{e.message}"
                      raise ActiveRecord::Rollback
                    end
                  end
                end
              end
              # CLEANUP
              next if not_missing.blank?

              not_missing.each do |locale|
                details_to_delete = missing_details.dig(resource.id.to_s, field.to_s, locale.to_s, "detail_list")
                if details_to_delete.present?
                  puts "Cleaning up #{locale}: #{resource.class.name}, id: #{resource.id}, field: #{field}"
                  Decidim::TranslationAddons::ReportDetail.where(id: details_to_delete).destroy_all
                end
              end
            end
          end
        end
      end
    end
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:translation_addons:choose_target_plugins"].invoke
end
