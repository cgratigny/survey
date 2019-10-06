module HummingbirdSurvey
  module Surveyable
    extend ActiveSupport::Concern

    included do
      has_one :survey, as: :surveyable, dependent: :destroy
      after_commit :initialize_survey, on: :create
    end

    def initialize_survey
      self.create_survey!(surveyable: self) unless survey.present?
    end

  end
end
