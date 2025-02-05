# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class UnreportDetail < Decidim::Command
      def initialize(report_detail, current_user)
        @report_detail = report_detail
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) unless [report_detail, current_user].all?

        unreport_detail
        broadcast(:ok)
      end

      private

      attr_reader :report_detail, :current_user

      def unreport_detail
        Decidim.traceability.perform_action!(
          :unreport_detail,
          @report_detail,
          @current_user,
          @report_detail.log_attributes.merge({ action_user_id: @current_user_id })
        ) do
          @report_detail.destroy!
        end
      end
    end
  end
end
