# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class RequestTranslation < Decidim::Command
      def initialize(report, current_user)
        @report = report
        @current_user = current_user
        @default_locale = @report.resource.respond_to?(:organization) ? @report.resource.organization.default_locale.to_s : Decidim.available_locales.first.to_s
      end

      def call
        return broadcast(:invalid) if @report.blank? || @current_user.blank?
        return broadcast(:not_missing) if report.field_with_merged_machine_translations[@report.locale].present?
        return broadcast(:missing_default_locale) if report.field_with_merged_machine_translations[@default_locale].blank?

        request_translation
        broadcast(:ok)
      end

      private

      attr_reader :report, :current_user

      def request_translation
        Decidim.traceability.perform_action!(
          :request_translation,
          @report,
          @current_user,
          resource_type: @report.resource.class.name, resource_id: @report.resource.id, field: @report.field_name, locale: @report.locale
        ) do
          report.auto_translation_retry_count += 1
          report.translation_last_retry_on = Time.current
          report.save!
          Decidim::MachineTranslationFieldsJob.perform_later(
            report.resource,
            report.field_name,
            report.field_with_merged_machine_translations[@default_locale],
            report.locale,
            source_locale
          )
          report
        end
      end
    end
  end
end
