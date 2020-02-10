module HummingbirdSurvey
  module QuestionModule
    extend ActiveSupport::Concern

    included do

      COLUMNS = {
        hint: {
          hint: ""
        }
      }

      store_accessor :data, *COLUMNS.keys

      has_one :survey_item, as: :survey_itemable
      has_many :survey_question_options

      # want to make sure no show ifs try to reference a question that's not there anymore
      has_many :show_ifs, dependent: :destroy

      classy_enum_attr :question_type, enum: "SurveyQuestionType", allow_blank: true

      store_accessor :data, [:answer_list, :linked_field_name, :country_question_id, *SurveyQuestionType.new.all_fields]

      scope :by_type, ->(given_type) { where(question_type: given_type.to_s) }
      accepts_nested_attributes_for :survey_question_options, allow_destroy: true

      # validates :label, :question_type, presence: true
    end

    module ClassMethods
      def data_fields
        COLUMNS.keys
      end
    end

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

    def requires_country_link?
      question_type.present? ? question_type.region_select? : false
    end

    def fields
      (question_type.present? && question_type.fields.any?) ? question_type.fields : false
    end

    def actually_required?(flat_answer_data)
      required? && survey_item.full_display?(flat_answer_data)
    end

    def full_path
      full_path = full_path_from_item(self.survey_item, self.label)
    end

    def full_path_from_item(survey_item, path_so_far)
      parent = survey_item.parent

      if parent.is_a?(SurveyPage)
        "Page #{parent.page_number}: #{parent.title} -> #{path_so_far}"
      elsif parent.is_a?(SurveySection)
        full_path_from_item(parent.survey_item, "#{parent.title} -> #{path_so_far}")
      else
        path_so_far
      end
    end
  end
end
