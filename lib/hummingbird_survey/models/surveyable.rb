module HummingbirdSurvey
  module Surveyable
    extend ActiveSupport::Concern

    included do
      has_one :survey, as: :surveyable, dependent: :destroy
    end
end
