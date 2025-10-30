module Decisions
  class CustomWrapper < SimpleDelegator
    private

    def claim_type
      @claim_type ||= multi_step_form_session['request_type']
    end

    def nsm
      @nsm ||= claim_type == Payments::ClaimType::NSM.to_s
    end

    def nsm_supplemental
      @nsm_supplemental ||= claim_type == Payments::ClaimType::NSM_SUPPLEMENTAL.to_s
    end

    def nsm_appeal
      @nsm_appeal ||= claim_type == Payments::ClaimType::NSM_APPEAL.to_s
    end

    def nsm_amendment
      @nsm_amendment ||= claim_type == Payments::ClaimType::NSM_AMENDMENT.to_s
    end

    # :nocov:
    def ac
      @ac ||= claim_type == Payments::ClaimType::AC.to_s
    end

    def ac_appeal
      @ac_appeal ||= claim_type == Payments::ClaimType::AC_APPEAL.to_s
    end

    def ac_amendment
      @ac_amendment ||= claim_type == Payments::ClaimType::AC_AMENDMENT.to_s
    end
    # :nocov:
  end
end
