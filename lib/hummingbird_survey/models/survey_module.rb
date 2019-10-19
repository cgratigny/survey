module HummingbirdSurvey
  module SurveyModule
    extend ActiveSupport::Concern

    included do
      COLUMNS = {
        save_pdf: {
          hint: "Save results as pdf. Pdf will be encrypted by default",
          type: "checkbox"
        }
      }

      store_accessor :configuration, *COLUMNS.keys

      belongs_to :surveyable, polymorphic: true
      has_many :survey_links

      attr_accessor :sub_obj # temporary object used to further granularize surveys - one survey can be used for multiple objects. Set this before you use the other methods

      has_many :survey_pages, dependent: :destroy
    end

    module ClassMethods
      def field_names
        COLUMNS.keys
      end
    end

    def survey_link_for(surveyed_obj)
      return nil unless surveyed_obj.present?
      survey_link = SurveyLink.find_or_create_by(survey: self, surveyed: surveyed_obj)
    end

    def surveyed_data_for(surveyed_obj)
      if surveyed_obj.blank?
        Hash.new
      else
        survey_link = survey_link_for(surveyed_obj)
        if survey_link.present?
          if sub_obj.present?
            survey_link.answers_data["#{sub_obj.class.name}_#{sub_obj.id}"] || {}
          else
            survey_link.answers_data
          end
        else
          {}
        end
      end
    end

    def answer_for_question(surveyed_obj, question_id)
      surveyed_data = surveyed_data_for(surveyed_obj)
      answer = ""

      surveyed_data.each do |page_key, page_data|
        answer = answer_for_question_in_container(page_data["items"], question_id)
        break if answer.present?
      end

      answer
    end

    def answer_for_question_in_container(container_data, question_id)
      container_data.each do |item_key, item_data|
        if item_key.start_with?("question")
          if item_key.end_with?(question_id.to_s)
            return item_data["value"]
          end
        elsif item_key.start_with?("section")
          return answer_for_question_in_container(item_data["items"], question_id)
        end
      end

      ""
    end

    def questions_linked_to(field_name)
      linked_questions = []
      return linked_questions if field_name.blank?

      survey_pages.each do |page|
        linked_questions += questions_in_container_linked_to(page, field_name)
      end

      linked_questions.flatten
    end

    def questions_in_container_linked_to(container, field_name)
      linked_questions = []
      return linked_questions if field_name.blank?

      container.survey_items.each do |item|
        actual_item = item.survey_itemable
        if actual_item.is_a?(SurveyQuestion)
          if actual_item.linked_field_name.to_s == field_name.to_s
            linked_questions << actual_item
          end
        elsif actual_item.is_a?(SurveySection)
          linked_questions += questions_in_container_linked_to(actual_item, field_name)
        end
      end

      linked_questions.flatten
    end

    def request_data_for(surveyed_obj)
      if surveyed_obj.blank?
        Hash.new
      else
        survey_link = survey_link_for(surveyed_obj)
        survey_link.present? ? survey_link.request_data : {}
      end
    end

    def set_surveyed_data_for!(surveyed_obj, target_data, request = nil)
      survey_link = survey_link_for(surveyed_obj)
      return false unless survey_link.present?

      survey_link.answers_data = target_data

      if request.present? && request.is_a?(ActionDispatch::Request)
        survey_link.request_data = { completed_at: Time.zone.now, ip_address: request.remote_ip, browser: request.user_agent, path: request.path }
      end

      survey_link.save(validate: false)
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
