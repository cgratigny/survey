module HummingbirdSurvey
  module QuestionOptionModule
    extend ActiveSupport::Concern

    included do
      belongs_to :survey_question
      validates :name, :survey_question, presence: true
    end
  end
end
