# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class RequestTranslation < Decidim::Command
      def initialize(report, current_user)
        @report = report
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) if @report.blank? || @current_user.blank?

        request_translation
        broadcast(:ok)
      end

      private

      attr_reader :resource_instance, :report, :current_user

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
          source_locale = report.resource.respond_to?(:organization) ? resource.organization.default_locale.to_s : Decidim.available_locales.first.to_s
          Decidim::MachineTranslationFieldsJob.perform_later(
            report.resource,
            report.field_name,
            resource_field_value(
              previous_changes,
              field,
              source_locale
            ),
            report.locale,
            source_locale
          )
          report
        end
      end
    end
  end
end
