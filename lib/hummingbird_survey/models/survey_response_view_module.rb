module HummingbirdSurvey
  module SurveyResponseViewModule
    extend ActiveSupport::Concern

    included do
      belongs_to :survey
    end

    def questions
      SurveyQuestion.where(id: question_ids)
    end

    def question_ids
      ids = []
      self.data["questions"].each do |key, value|
        ids << key.to_i if self.question_enabled?(SurveyQuestion.find_by(id: key))
      end
      ids
    end

    def question_enabled?(survey_question)
      return unless data["questions"].present?
      ActiveModel::Type::Boolean.new.cast(self.data["questions"]["#{survey_question.id}"])
    end

  end
end
