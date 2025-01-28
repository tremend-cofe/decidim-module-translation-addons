# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class AcceptDetail < Decidim::Command
      def initialize(report_detail, current_user, new_value)
        @report_detail = report_detail
        @current_user = current_user
        @new_value = new_value
      end

      def call
        return broadcast(:invalid) if @report_detail.blank? || @current_user.blank? || new_value.blank?

        accept_detail
        broadcast(:ok)
      end

      private

      attr_reader :report_detail, :current_user, :new_value

      def accept_detail
        Decidim.traceability.perform_action!(
          :accept_detail,
          @report_detail,
          @current_user,
          {
            report_id: @report_detail.report.id,
            resource_type: @report_detail.report.class.name,
            field_name: @report_detail.report.field_name,
            resource_id: @report_detail.report.id,
            locale: @report_detail.report.locale,
            fix_suggestion: @report_detail.fix_suggestion,
            reporting_user_id: @report_detail.decidim_user_id,
            action_user_id: @current_user_id,
            new_value: @new_value
          }
        ) do
          field_object = @report_detail.report.resource[@report_detail.report.field_name]
          field_object.merge!(@report_detail.report.locale => @new_value)
          if field_object.key?("machine_translations") && field_object["machine_translations"].key?(@report_detail.report.locale)
            field_object["machine_translations"].except!(@report_detail.report.locale)
          end
          @report_detail.report.resource.update_column @report_detail.report.field_name.to_sym, field_object
          @report_detail.report.destroy
        end
      end
    end
  end
end
