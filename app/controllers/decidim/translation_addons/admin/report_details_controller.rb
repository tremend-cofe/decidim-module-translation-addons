# frozen_string_literal: true

module Decidim
  module TranslationAddons
    module Admin
      # Controller used to manage translation reports for the current
      # organization
      class ReportDetailsController < Decidim::TranslationAddons::Admin::ApplicationController
        helper Decidim::PaginateHelper
        helper Decidim::ResourceHelper
        include Decidim::TranslationAddons::Admin::ReportDetails::Filterable

        layout "decidim/admin/global_moderations"
        before_action :set_translation_details_breadcrumb_item

        def index
          @report_details = filtered_collection
        end

        def accept
          Decidim::TranslationAddons::ReportDetail.find params[:report_id]
          # WIP
        end

        def decline
          # enforce_permission_to :unreport, authorization_scope

          report = Decidim::TranslationAddons::ReportDetail.find params[:id]

          Decidim::TranslationAddons::UnreportDetail.call(report, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("reportable.unreport.success", scope: "decidim.moderations.admin")
              redirect_to report_report_details_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
              redirect_to report_report_details_path
            end
          end
        end

        def base_query_finder
          Decidim::TranslationAddons::ReportDetail.where(decidim_translation_addons_report_id: params[:report_id])
        end

        def collection
          @collection ||= Decidim::TranslationAddons::ReportDetail.where(decidim_translation_addons_report_id: params[:report_id])
        end

        def report_details
          @report_details ||= filtered_collection
        end

        def set_translation_details_breadcrumb_item
          controller_breadcrumb_items << {
            label: t("decidim.admin.reports.details_page_title"),
            url: decidim_admin_translation_addons.root_path,
            active: true
          }
        end
      end
    end
  end
end
