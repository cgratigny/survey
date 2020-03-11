module HummingbirdSurvey
  module SurveyResponseModule
    extend ActiveSupport::Concern

    included do
      belongs_to :survey
      belongs_to :surveyed, polymorphic: true
    end

    def completed?
      survey.completed_by?(surveyed)
    end

  end
end
