module HummingbirdSurvey
  module Questionable
    include Duplicator

    has_one :survey_item, as: :survey_itemable

    # want to make sure no show ifs try to reference a question that's not there anymore
    has_many :show_ifs, dependent: :destroy

    classy_enum_attr :question_type, enum: "SurveyQuestionType", allow_blank: true

    store_accessor :data, :answer_list

    def survey_page
      survey_item.present? ? survey_item.survey_page : nil
    end

    def survey
      survey_page.present? ? survey_page.survey : nil
    end

    def qkey
      "question_#{self.id}"
    end

    def requires_answer_list?
      question_type.present? ? question_type.requires_answer_list? : false
    end

    def actually_required?(flat_answer_data)
      ap "checking if question #{label} #{id} is actually required"
      ap "required? #{required?}"
      ap "full display? #{survey_item.full_display?(flat_answer_data)}"
      required? && survey_item.full_display?(flat_answer_data)
    end

  end
end
