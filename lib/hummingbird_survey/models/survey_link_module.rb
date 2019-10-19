module HummingbirdSurvey
  module SurveyLinkModule
    extend ActiveSupport::Concern

    included do
      belongs_to :survey
      belongs_to :surveyed, polymorphic: true
    end
  end
end
