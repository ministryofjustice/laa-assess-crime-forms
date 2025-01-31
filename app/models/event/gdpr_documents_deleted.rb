class Event
  class GdprDocumentsDeleted < Event
    def self.construct(submission:)
      new(
        submission_version: submission.current_version,
      )
    end

    def body
      t('body')
    end
  end
end
