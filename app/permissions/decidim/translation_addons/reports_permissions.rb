# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class ReportsPermissions < DefaultPermissions
      def permissions
        return permission_action unless user

        allow! if permission_action.subject == :report && permission_action.action == :create

        permission_action
      end
    end
  end
end
