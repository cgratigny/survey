module HummingbirdSurvey
  module Survey
    extend ActiveSupport::Concern

    included do
      belongs_to :surveyable, polymorphic: true

      attr_accessor :sub_obj # temporary object used to further granularize surveys - one survey can be used for multiple objects. Set this before you use the other methods

      has_many :survey_pages, dependent: :destroy
    end

    def surveyed_data_for(surveyed_obj)
      if sub_obj.present?
        surveyed_obj.data["survey_#{self.id}_#{sub_obj.class.name}_#{sub_obj.id}"] || {}
      else
        surveyed_obj.data["survey_#{self.id}"] || {}
      end
    end

    def set_surveyed_data_for!(surveyed_obj, target_data)
      if sub_obj.present?
        surveyed_obj.data["survey_#{self.id}_#{sub_obj.class.name}_#{sub_obj.id}"] = target_data
      else
        surveyed_obj.data["survey_#{self.id}"] = target_data
      end

      surveyed_obj.save(validate: false)
    end

    def current_page_for(surveyed_obj)
      surveyed_data = surveyed_data_for(surveyed_obj)
      incomplete_page = nil

      survey_pages.in_order.each do |page|
        page_data = surveyed_data["page_#{page.id}"]
        incomplete_page = page if page_data.blank? || page_data["completed_at"].blank?
        break if incomplete_page.present?
      end

      incomplete_page
    end

    def completed_by?(surveyed_obj)
      current_page_for(surveyed_obj).nil?
    end

    def furthest_page_completed_at(surveyed_obj)
      surveyed_data = surveyed_data_for(surveyed_obj)
      completed_at = nil

      survey_pages.in_order.each do |page|
        page_data = surveyed_data["page_#{page.id}"]
        if page_data.present? && page_data["completed_at"].present?
          completed_at = page_data["completed_at"]
        else
          break
        end
      end

      completed_at
    end

    def start_page_for!(given_page, surveyed_obj)
      surveyed_data = surveyed_data_for(surveyed_obj)
      page_key = "page_#{given_page.id}"

      return if surveyed_data[page_key].present? && surveyed_data[page_key]["started_at"].present?

      surveyed_data[page_key] = {} if surveyed_data[page_key].blank?
      surveyed_data[page_key]["started_at"] = Time.zone.now
      set_surveyed_data_for!(surveyed_obj, surveyed_data)
    end

    def complete_page_for!(given_page, surveyed_obj)
      surveyed_data = surveyed_data_for(surveyed_obj)
      page_key = "page_#{given_page.id}"

      surveyed_data[page_key] = {} if surveyed_data[page_key].blank?
      surveyed_data[page_key]["started_at"] = Time.zone.now if surveyed_data[page_key]["started_at"].blank?
      surveyed_data[page_key]["completed_at"] = Time.zone.now
      set_surveyed_data_for!(surveyed_obj, surveyed_data)
    end

    # used to build the list of connected questions
    def survey_questions
      ids = []

      survey_pages.find_each do |page|
        ids += page.survey_question_ids
      end

      SurveyQuestion.where(id: ids).distinct
    end

    def add_page!(title:nil, number: nil)
      number = survey_pages.maximum(:page_number).to_i + 1 if number.blank?

      title = "Page #{number}" if title.blank?

      page = SurveyPage.create!(survey: self, title: title, page_number: number)
    end

    def duplicate!
      target_survey = super

      survey_pages.each do |page|
        target_page = page.duplicate!
        target_page.survey = target_survey
        target_page.save!
      end

      target_survey.reload
      target_survey
    end
  end
end
