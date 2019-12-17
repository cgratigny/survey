module HummingbirdSurvey
  module SurveyedModule
    extend ActiveSupport::Concern

    included do
      has_one :survey_response, as: :surveyed
    end
  end
end
