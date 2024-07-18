require 'rails_helper'

RSpec.describe DashboardsController do
  describe '#show' do
    context 'dashboard ids not set' do
      let(:search_form) { nil }
      let(:search_form_instance) { instance_double(SearchForm) }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('METABASE_PA_DASHBOARD_IDS')
                                     .and_return(nil)
        allow(ENV).to receive(:fetch).with('METABASE_NSM_DASHBOARD_IDS')
                                     .and_return(nil)
        allow(FeatureFlags).to receive(:nsm_insights).and_return(double(enabled?: true))
        allow(subject).to receive(:authorize_supervisor).and_return(true)
        allow(SearchForm).to receive(:new).and_return(search_form_instance)
        allow(SearchForm).to receive_message_chain(:new, :valid?).and_return(true)
        allow(SearchForm).to receive_message_chain(:new, :execute).and_return({})
        get :show, params: { nav_select:, search_form: }
      end

      context 'selected tab is search and user has executed a valid search' do
        let(:nav_select) { 'search' }
        let(:search_form) { { query: 'query' } }

        it 'generates a SearchForm' do
          expect(subject.instance_variable_get(:@search_form)).to eq(search_form_instance)
        end
      end

      context 'selected tab is prior authority' do
        let(:nav_select) { 'prior_authority' }

        it 'returns no urls' do
          expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
        end
      end

      context 'selected tab is nsm' do
        let(:nav_select) { 'nsm' }

        it 'returns no urls' do
          expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
        end
      end

      context 'invalid service provided' do
        let(:nav_select) { 'random' }

        it 'returns no ids' do
          expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
        end
      end
    end
  end
end
