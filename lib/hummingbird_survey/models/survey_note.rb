module HummingbirdSurvey
  class SurveyNote < ApplicationRecord
    include Duplicator

    has_one :survey_item, as: :survey_itemable

    def survey_page
      survey_item.present? ? survey_item.survey_page : nil
    end

    def survey
      survey_page.present? ? survey_page.survey : nil
    end

  end
end
