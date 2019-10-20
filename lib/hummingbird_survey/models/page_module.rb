module HummingbirdSurvey
  module PageModule
    extend ActiveSupport::Concern

    included do
      belongs_to :survey

      has_many :survey_items, as: :parent, dependent: :destroy

      scope :in_order, -> { order("survey_pages.page_number ASC") }
      scope :last_page, -> { order("survey_pages.page_number DESC").first }
    end

    def last_page?
      self == self.class.last_page
    end

    # to end the recursion for survey_items and children
    def survey_page
      self
    end

    # to end the recursion for surevey_items and children display
    def display?(flat_answer_data)
      true
    end

    # to end the recursion for surevey_items and children display
    def full_display?(flat_answer_data)
      true
    end

    def previous_page
      survey.survey_pages.where("survey_pages.page_number < ?", self.page_number).in_order.last
    end

    def next_page
      survey.survey_pages.where("survey_pages.page_number > ?", self.page_number).in_order.first
    end

    def first_page?
      previous_page.blank?
    end

    def last_page?
      next_page.blank?
    end

    def display_title_with_number
      "Page #{page_number}#{" - #{title}" if title.present?}"
    end

    def page_started_by?(surveyed_obj)
      page_data = surveyed_data_for(surveyed_obj)
      page_data.present? && page_data["started_at"].present?
    end

    def page_completed_by?(surveyed_obj)
      page_data = surveyed_data_for(surveyed_obj)
      page_data.present? && page_data["completed_at"].present?
    end

    def survey_questions
      SurveyQuestion.where(id: survey_question_ids).distinct
    end

    def survey_question_ids
      ids = []

      survey_items.find_each do |item|
        ids += survey_question_ids_for_item(item)
      end

      ids.uniq
    end

    def survey_question_ids_for_item(given_item)
      ids = []

      if given_item.survey_itemable.is_a?(SurveyQuestion)
        ids << given_item.survey_itemable_id
      elsif given_item.survey_itemable.is_a?(SurveySection)
        given_item.survey_itemable.survey_items.find_each do |item|
          ids += survey_question_ids_for_item(item)
        end
      end

      ids.uniq
    end

    def surveyed_data_for(surveyed_obj)
      survey_data = self.survey.surveyed_data_for(surveyed_obj) || {}

      survey_data["page_#{self.id}"] || {}
    end

    def duplicate!
      target_page = super

      survey_items.each do |survey_item|
        target_item = survey_item.duplicate!
        target_item.parent = target_page
        target_item.save!
      end

      target_page
    end
  end
end
