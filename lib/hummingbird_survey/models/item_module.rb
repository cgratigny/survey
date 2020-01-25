module HummingbirdSurvey
  module ItemModule
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, polymorphic: true
      belongs_to :survey_itemable, polymorphic: true, dependent: :destroy

      has_one :show_if, as: :showable, dependent: :destroy

      scope :in_order, -> { order("item_number ASC") }

      # allow survey question to be a relation for nested forms
      has_one :self_ref, class_name: self.to_s, foreign_key: :id
      has_one :survey_question, through: :self_ref, source: :survey_itemable, source_type: "SurveyQuestion"
      accepts_nested_attributes_for :survey_question, allow_destroy: true

      scope :by_survey_itemable_type, -> (survey_itemable_type) { where(survey_itemable_type: survey_itemable_type)}
    end

    def survey_page
      parent.present? ? parent.survey_page : nil
    end

    def survey
      survey_page.present? ? survey_page.survey : nil
    end

    def display?(flat_answer_data)
      show_if.blank? || show_if.display?(flat_answer_data)
    end

    def full_display?(flat_answer_data)
      display?(flat_answer_data) && (parent.blank? || parent.full_display?(flat_answer_data))
    end

    def show_if_parent
      show_if.present? ? "question_#{show_if.survey_question_id}" : nil
    end

    def show_if_op
      show_if.present? ? show_if.condition.to_s : nil
    end

    def show_if_val
      show_if.present? ? show_if.target_value.to_s : nil
    end

    def duplicate!(args = {})
      target_item = super(args)

      if show_if.present?
        target_show_if = show_if.duplicate!
        target_show_if.showable = target_item
        target_show_if.save!
      end

      target_itemable = survey_itemable.duplicate!
      target_itemable.survey_item = target_item
      target_itemable.save!

      if survey_itemable.is_a?(SurveyQuestion)
        survey_itemable.survey_question_options.each do |survey_question_option|
          target_survey_question_option = survey_question_option.duplicate!
          target_survey_question_option.update!(survey_question: target_itemable)
        end
      end

      target_item
    end
  end
end
