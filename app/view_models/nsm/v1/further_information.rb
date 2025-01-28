module Nsm
  module V1
    class FurtherInformation < BaseViewModel
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TextHelper

      attribute :submission
      attribute :information_supplied
      attribute :information_requested
      attribute :requested_at
      attribute :caseworker_id
      attribute :documents

      def key
        'provider_update'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title", date: requested_at_str)
      end

      def data
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.caseworker"),
            value: caseworker
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.information_request"),
            value: multiline_text(information_requested)
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.provider_response"),
            value: provider_response
          },
        ]
      end

      def provider_response
        response_content = [simple_format(information_supplied)]

        if gdpr_documents_deleted?
          response_content << ApplicationController.renderer.render(partial: 'shared/gdpr_documents_deleted')
        else
          response_content.concat(uploaded_documents.flat_map { [tag.br, document_link(_1)] })
        end

        safe_join(response_content)
      end

      def document_link(document)
        link_to(
          document.file_name,
          url_helpers.nsm_further_information_download_path(
            document.file_path,
            file_name: document.file_name,
          )
        )
      end

      def requested_at_str
        DateTime.parse(requested_at).to_fs(:stamp)
      end

      def uploaded_documents
        return [] if documents.nil?

        @uploaded_documents ||= documents.map { Document.new(_1) }
      end

      def caseworker
        User.load(caseworker_id)&.display_name
      end

      private

      def url_helpers
        Rails.application.routes.url_helpers
      end

      def gdpr_documents_deleted?
        submission.data.key?('gdpr_documents_deleted') ? submission.data['gdpr_documents_deleted'] : false
      end
    end
  end
end
