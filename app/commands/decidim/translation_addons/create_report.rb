# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class CreateReport < Decidim::Command
      def initialize(form, resource_instance, current_user)
        @resource_instance = resource_instance
        @field = form.field
        @locale = form.locale
        @reason = form.reason
        @current_user = current_user
        @fix_suggestion = form.detail
      end

      def call
        return broadcast(:invalid) if @resource_instance.blank? || @field.blank? || @locale.blank? || @current_user.blank? || @reason.blank?

        create_report
        broadcast(:ok)
      end

      private

      attr_reader :resource_instance, :field, :locale, :current_user, :reason, :fix_suggestion

      def create_report
        @report = Decidim.traceability.perform_action!(
          :create,
          Decidim::TranslationAddons::Report,
          @current_user,
          visibility: "public-only"
        ) do
          report = Decidim::TranslationAddons::Report.where(decidim_resource_id: resource_instance.id, decidim_resource_type: resource_instance.class.name, field_name: field,
                                                            locale:).first
          if report.blank?
            report = Decidim::TranslationAddons::Report.new(
              decidim_resource_type: resource_instance.class.name,
              decidim_resource_id: resource_instance.id,
              field_name: field,
              locale:
            )
            report.save!
          end

          if report.present?
            detail = Decidim::TranslationAddons::ReportDetail.new(
              decidim_user_id: current_user.id,
              decidim_translation_addons_report_id: report.id,
              reason:,
              fix_suggestion:
            )
            detail.save!
          end
          report.reload
        end
      end
    end
  end
end
