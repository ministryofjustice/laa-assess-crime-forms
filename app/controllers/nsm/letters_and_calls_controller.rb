module Nsm
  class LettersAndCallsController < Nsm::BaseController
    layout nil

    include Nsm::AdjustmentConcern

    FORMS = {
      'letters' => LettersCallsForm::Letters,
      'calls' => LettersCallsForm::Calls
    }.freeze

    def index
      authorize(claim, :show?)
      records = BaseViewModel.build(:letters_and_calls_summary, claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      summary = nil
      scope = :letters_and_calls
      pagy = nil
      type_changed_records = BaseViewModel.build(:work_item, claim, 'work_items').filter do |work_item|
        work_item.work_type != work_item.original_work_type
      end

      render 'nsm/review_and_adjusts/show',
             locals: { claim:, records:, summary:, claim_summary:, core_cost_summary:, pagy:, scope:, type_changed_records: }
    end

    def adjusted
      authorize(claim, :show?)
      records = BaseViewModel.build(:letters_and_calls_summary, claim)
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)
      scope = :letters_and_calls
      pagy = nil

      render 'nsm/adjustments/show', locals: { claim:, records:, claim_summary:, core_cost_summary:, pagy:, scope: }
    end

    def show
      authorize(claim)
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == controller_params[:id]
      end

      render locals: { claim:, item: }
    end

    def edit
      authorize(claim)
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == controller_params[:id]
      end
      form = form_class.new(claim:, item:, **item.form_attributes)

      render locals: { claim:, item:, form: }
    end

    def update
      authorize(claim)
      item = BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls').detect do |model|
        model.type.value == controller_params[:id]
      end
      form = form_class.new(claim:, item:, **form_params)

      if form.save!
        redirect_to nsm_claim_letters_and_calls_path(claim)
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(controller_params[:claim_id])
    end

    def form_class
      FORMS[controller_params[:id]]
    end

    def form_params
      params.require(:"nsm_letters_calls_form_#{params[:id]}").permit(
        :uplift,
        :count,
        :explanation,
      ).merge(
        current_user: current_user,
        type: params[:id]
      )
    end

    def controller_params
      params.permit(:claim_id, :id)
    end

    def param_validator
      Nsm::LettersAndCallsParams.new(controller_params)
    end
  end
end
