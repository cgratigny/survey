module HummingbirdSurvey
  module ShowIfModule
    extend ActiveSupport::Concern

    included do
      belongs_to :showable, polymorphic: true
      belongs_to :answer
      classy_enum_attr :condition, enum: "ShowIfCondition", allow_blank: true
    end

    def parent
      self.class.const_get(showable_type).find(showable_id)
    end

    def value_matches_parent?(string_answer)
      string_answer = string_answer.to_s

      result = false
      case operator
      when "="
        result = (string_answer == parent_value)
      when "!="
        result = (string_answer != parent_value)
      else
        raise "Cannot determine show if operator: #{operator}"
      end
      result
    end

    def answer_same_page?
      answer.present? && answer.page_obj == showable.page_obj
    end

    # overriden in dragonfly to use the given_questionnaire
    # override in hummingbird to pass a hash instead and use that
    def find_answer_value(given_questionnaire = nil)
      if answer.present?
        answer.find_value
      else
        ""
      end
    end

    def show?
      answer_same_page? || value_matches_parent?(find_answer_value)
    end

    ### Code for the new ShowIfs used in the new Survey code ###
    def survey_question
      SurveyQuestion.find_by(id: survey_question_id)
    end

    def survey_page
      showable.present? ? showable.survey_page : nil
    end

    def survey
      survey_page.present? ? survey_page.survey : nil
    end

    # needs a hash where the keys are in the form of "question_#{question_id}"
    # and the values are the answers to that particular question.
    def display?(flat_answer_data)
      if flat_answer_data.is_a?(Hash) && condition.present?
        given_value = flat_answer_data["question_#{survey_question_id}"]

        condition.resolve(target_value.to_s.upcase, given_value.to_s.upcase)
      else
        true
      end
    end
  end
end
