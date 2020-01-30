module HummingbirdSurvey
  module SurveyResponseViewModule
    extend ActiveSupport::Concern

    included do
      belongs_to :survey
    end

    def responses_for_surveyed(surveyed_obj)
      responses = []
      questions.each do |question|
        responses << { answer: answer_for_question(surveyed_obj, question.id), question: question }
      end
      responses
    end

    # todo put this in a logical order
    def questions
      SurveyQuestion.joins(:survey_item).order("survey_items.item_number ASC").where(id: question_ids)
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
