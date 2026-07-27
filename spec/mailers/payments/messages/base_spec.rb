# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::Messages::Base do
  describe '#template' do
    it 'throws a not implemented exception' do
      expect { subject.template }.to raise_error(NotImplementedError)
    end
  end

  describe '#report_name' do
    it 'throws a not implemented exception' do
      expect { subject.report_name }.to raise_error(NotImplementedError)
    end
  end

  describe '#metabase_question_id' do
    it 'raises a not implemented exception' do
      expect { subject.metabase_question_id }.to raise_error(NotImplementedError)
    end
  end
end
