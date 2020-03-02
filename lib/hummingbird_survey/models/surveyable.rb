module HummingbirdSurvey
  module Surveyable
    extend ActiveSupport::Concern

    included do
      has_one :survey, as: :surveyable, dependent: :destroy
      after_commit :initialize_survey, on: :create
    end

    def initialize_survey
      reload
      return if survey.present?

      survey = self.create_survey!(surveyable: self, display_name: self.to_s)
      page = survey.add_page!(title: "Page 1", number: 1)

      survey_section = SurveySection.create!(title: "Section 1")
      item = SurveyItem.create!(survey_itemable: survey_section, parent: page, item_number: 1)
    end

    # used to link fields from the survey target with answers in the survey
    def linked_field_names
      {}
    end

    def update_linked_fields_for(surveyed_obj)
      return unless surveyed_obj.present?

      linked_field_names.each do |field_name, field_options|
        questions = self.survey.questions_linked_to(field_name)
        question_id = questions.first.present? ? questions.first.id : nil
        next if question_id.blank?

        answer_value = self.survey.answer_for_question(surveyed_obj, question_id)

        if answer_value.present?
          surveyed_obj.send("#{field_name.to_s}=", answer_value)
          surveyed_obj.save(validate: false)
        end
      end
    end

  end
end
