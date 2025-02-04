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
        include Decidim::SanitizeHelper

        layout "decidim/admin/global_moderations"
        before_action :set_translation_details_breadcrumb_item

        def index
          @report_details = filtered_collection
        end

        def accept
          @form = form(Decidim::TranslationAddons::Admin::AcceptTranslationForm).from_params(params, user: current_user)
          # report_detail = Decidim::TranslationAddons::ReportDetail.find @form.id
          Decidim::TranslationAddons::AcceptDetail.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("report_details.accept.success", scope: "decidim.admin")
              redirect_to reports_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("report_details.accept.invalid", scope: "decidim.admin")
              redirect_to report_report_details_path
            end
          end
        end

        def decline
          report = Decidim::TranslationAddons::ReportDetail.find params[:id]

          Decidim::TranslationAddons::UnreportDetail.call(report, current_user) do
            on(:ok) do
              report = Decidim::TranslationAddons::ReportDetail.where(id: params[:id]).first
              if report.present?
                flash[:notice] = I18n.t("report_details.decline.success", scope: "decidim.admin")
                redirect_to report_report_details_path
              else
                flash[:notice] = I18n.t("report_details.decline.success_with_report_deleted", scope: "decidim.admin")
                redirect_to reports_path
              end
            end

            on(:invalid) do
              flash[:alert] = I18n.t("report_details.decline.invalid", scope: "decidim.admin")
              redirect_to report_report_details_path
            end
          end
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
