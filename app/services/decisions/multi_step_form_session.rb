module Decisions
  class MultiStepFormSession
    EXPIRES_IN = 2.hours

    attr_reader :session, :id, :process

    class << self
      def find(process:, session:, session_id:)
        new(process, session, session_id)
      end
    end

    def initialize(process:, session:, session_id:)
      @process = process
      @session = session
      @id = session_id
      create!
    end

    def answers
      data['answers']
    end

    def attribute_names
      answers.keys
    end

    def [](hash_key)
      answers[hash_key.to_s]
    end

    def []=(hash_key, hash_value)
      answers[hash_key.to_s] = hash_value
    end

    def destroy!
      session.delete(key)
    end

    private

    def create!
      now = Time.current
      if session[key].blank? || expired?(session[key])
        session[key] = {
          'answers' => {},
          'created_at' => now.iso8601,
          'updated_at' => now.iso8601,
        }
      else
        session[key]
      end
    end

    def key
      "#{process}:#{id}"
    end

    def data
      session[key]
    end

    def expired?(hash)
      return false unless EXPIRES_IN

      updated_at = begin
        Time.iso8601(hash['updated_at'])
      rescue StandardError
        nil
      end
      updated_at && updated_at < EXPIRES_IN.ago
    end
  end
end
