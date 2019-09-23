module HummingbirdSurvey
  module Itemable
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, polymorphic: true
      belongs_to :survey_itemable, polymorphic: true, dependent: :destroy

      has_one :show_if, as: :showable, dependent: :destroy

      scope :in_order, -> { order("item_number ASC") }
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

    def duplicate!
      target_item = super

      if show_if.present?
        target_show_if = show_if.duplicate!
        target_show_if.showable = target_item
        target_show_if.save!
      end

      target_itemable = survey_itemable.duplicate!
      target_itemable.survey_item = target_item
      target_itemable.save!

      target_item
    end
  end
end
