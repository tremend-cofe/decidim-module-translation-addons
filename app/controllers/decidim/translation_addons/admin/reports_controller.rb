# frozen_string_literal: true

module Decidim
  module TranslationAddons
    module Admin
      # Controller used to manage translation reports for the current
      # organization
      class ReportsController < Decidim::TranslationAddons::Admin::ApplicationController
        include Decidim::PaginateHelper
        # include Decidim::Moderations::Admin::Filterable // To be implemented for Decidim::TranslationAddons::Admin::Filterable

        def index
          @reports = Decidim::TranslationAddons::Report.all
        end
      end
    end
  end
end
