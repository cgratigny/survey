module HummingbirdSurvey
  module Surveyable
    extend ActiveSupport::Concern

    included do
      has_one :survey, as: :surveyable, dependent: :destroy
      after_commit :initialize_survey, on: :create
    end

    def initialize_survey
      return if survey.present?
      
      survey = self.create_survey!(surveyable: self)
      page = survey.add_page!(title: "Page 1", number: 1)

      survey_section = SurveySection.create!(title: "Section 1")
      item = SurveyItem.create!(survey_itemable: survey_section, parent: page, item_number: 1)
    end

  end
end
