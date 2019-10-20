module HummingbirdSurvey
  module SurveyLinkModule
    extend ActiveSupport::Concern

    included do
      belongs_to :survey
      belongs_to :surveyed, polymorphic: true
      has_one_attached :answers_pdf
    end

    def generate_pdf
      HummingbirdSurvey::SurveyPdfCreatorService.new(survey_link: self).generate
    end

  end
end
