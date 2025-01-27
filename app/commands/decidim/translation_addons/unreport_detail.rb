# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class UnreportDetail < Decidim::Command
      def initialize(report, current_user)
        @report = report
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) if @report.blank? || @current_user.blank?

        unreport
        broadcast(:ok)
      end

      private

      attr_reader :resource_instance, :report, :current_user

      def unreport
        Decidim.traceability.perform_action!(
          :unreport,
          @report,
          @current_user,
          resource_type: @report.report.class.name, resource_id: @report.report.id, fix_suggestion: @report.fix_suggestion, user_id: @report.user.id
        ) do
          @report.destroy!
        end
      end
    end
  end
end
