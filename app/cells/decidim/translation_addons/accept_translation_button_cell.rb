# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class AcceptTranslationButtonCell < ButtonCell
      include ActionView::Helpers::FormOptionsHelper

      def accept_translation_modal
        render
      end

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.push(only_button? ? 1 : 0)
        hash.push(current_user.try(:id))
        hash.push(model.decidim_user_id == current_user.id ? 1 : 0)
        hash.push(model.class.name.gsub("::", ":"))
        hash.push(model.id)
        hash.join(Decidim.cache_key_separator)
      end

      def only_button?
        options[:only_button]
      end

      def modal_id
        options[:modal_id] || "acceptTranslationModal-#{model&.id}"
      end

      def accept_translation_form
        @raccept_report_form ||= Decidim::TranslationAddons::Admin::AcceptTranslationForm.from_params(rresource_id: model.id)
      end

      def accept_translation_path
        @accept_report_path ||= decidim_admin_translation_addons.accept_report_report_detail_path(id: model.id)
      end

      def builder
        Decidim::FormBuilder
      end

      def button_classes
        options[:button_classes] || "button button__sm button__text button__text-secondary"
      end

      def text
        t("decidim.translation_addons.admin.report_details.index.accept")
      end

      def html_options
        { data: { "dialog-open": current_user ? modal_id : "loginModal" } }
      end
    end
  end
end
