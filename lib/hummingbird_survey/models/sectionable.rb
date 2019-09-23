module HummingbirdSurvey
  module Sectionable

    has_one :survey_item, as: :survey_itemable

    has_many :survey_items, as: :parent, dependent: :destroy

    def survey_page
      survey_item.present? ? survey_item.survey_page : nil
    end

    def survey
      survey_page.present? ? survey_page.survey : nil
    end

    def display?(flat_answer_data)
      survey_item.display?(flat_answer_data)
    end

    def full_display?(flat_answer_data)
      survey_item.full_display?(flat_answer_data)
    end

    def duplicate!
      target_section = super

      survey_items.each do |survey_item|
        target_item = survey_item.duplicate!
        target_item.parent = target_section
        target_item.save!
      end

      target_section
    end
  end
end
