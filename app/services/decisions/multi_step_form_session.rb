module Decisions
  class MultiStepFormSession
    attr_reader :session, :id, :process

    def initialize(process:, session:, session_id:)
      @process = process
      @session = session
      @id = session_id
      create!
    end

    def answers
      data['answers']
    end

    def reset_answers
      data['answers'] = {}
    end

    def [](hash_key)
      answers[hash_key.to_s]
    end

    def []=(hash_key, hash_value)
      answers[hash_key.to_s] = hash_value.to_s
    end

    private

    def create!
      # rubocop:disable Rails/Presence
      if session[key].blank?
        session[key] = {
          'answers' => {}
        }
      else
        session[key]
      end
      # rubocop:enable Rails/Presence
    end

    def key
      "#{process}:#{id}"
    end

    def data
      session[key]
    end
  end
end
