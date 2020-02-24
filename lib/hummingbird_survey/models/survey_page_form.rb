module HummingbirdSurvey
  class SurveyPageForm
    include ActiveModel::Model

    attr_accessor :survey_page, :surveyed, :sub_obj, :request

    validate :required_questions_presence

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end

    def initialize(params)
      super
      @questions = []
      @required_questions = []
      survey_page.survey_questions.each do |question|
        @questions << question
        @required_questions << question if question.required?

        create_method "#{question.qkey}=" do |value|
          all_answer_data[question.qkey] = value
        end

        create_method question.qkey do
          all_answer_data[question.qkey]
        end
      end
    end

    def questions
      @questions
    end

    def required_questions
      @required_questions
    end

    def survey
      if @survey.blank?
        @survey = survey_page.survey
        @survey.sub_obj = sub_obj
      end

      @survey
    end

    def raw_data
      @raw_data ||= build_raw_data || {}
    end

    def all_answer_data
      @all_answer_data ||= build_answer_data || {}
    end

    def save_and_exit?
      @save_and_exit.present?
    end

    def permitted_params(params)
      if params[self.class.name.to_s.underscore].present?
        params[self.class.name.to_s.underscore].permit!
      else
        {}
      end
    end

    def parse_attributes(params)
      target_params = permitted_params(params)
      questions.each do |question|
        value = target_params[question.qkey]
        if value.is_a?(Array)
          value = value.reject(&:blank?)
        end
        send("#{question.qkey}=", value)
      end
      @save_and_exit = params["save_and_exit"]
    end

    def attributes=(params)
      parse_attributes(params)
    end

    def submit(params, should_validate = true)
      parse_attributes(params)
      save(should_validate)
    end

    def save(should_validate = true)
      if save_and_exit? || !should_validate || valid?
        target_page_data = build_final_page_data
        raw_data["page_#{survey_page.id}"] = target_page_data
        survey.set_surveyed_data_for!(surveyed, raw_data, request)

        if survey.surveyable.linked_field_names.any?
          survey.surveyable.update_linked_fields_for(surveyed)
        end

        surveyed.reload
        true
      else
        false
      end
    end

    private

    def required_questions_presence
      required_questions.each do |question|
        if question.question_type.checkbox_type?
          errors.add(question.qkey.to_sym, "is required") if question.actually_required?(all_answer_data) && send(question.qkey.to_sym).to_s != "1"
        elsif question.question_type.multi_select?
          errors.add(question.qkey.to_sym, "is required") if question.actually_required?(all_answer_data) && (send(question.qkey.to_sym).blank? || send(question.qkey.to_sym).empty?)
          errors.add(question.qkey.to_sym, "cannot have more than #{question.answer_limit.to_i} responses") if question.answer_limit.to_i > 0 && (send(question.qkey.to_sym).count > question.answer_limit.to_i)
        else
          errors.add(question.qkey.to_sym, "is required") if question.actually_required?(all_answer_data) && send(question.qkey.to_sym).blank?
        end
      end
    end

    def build_raw_data
      survey.surveyed_data_for(surveyed)
    end

    def build_answer_data
      @all_answer_data = {}

      raw_data.each do |page_id_str, page_data|
        page_data = {} if page_data.blank?

        page_data["items"] = {} if page_data["items"].blank?
        page_data["items"].each do |item_id_str, item_data|
          deduce_survey_item(item_id_str, item_data, page_id_str)
        end
      end

      @all_answer_data
    end

    def deduce_survey_item(item_id_str, item_data, page_id_str)
      if item_id_str.to_s.starts_with?("question")
        @all_answer_data[item_id_str.to_s] = item_data["value"]
      elsif item_id_str.to_s.starts_with?("section")
        item_data["items"].each do |sub_item_id_str, sub_item_data|
          deduce_survey_item(sub_item_id_str, sub_item_data, page_id_str)
        end
      end
    end

    def build_final_page_data
      result = {}

      result["started_at"] = raw_data["page_#{survey_page.id}"]["started_at"] if raw_data["page_#{survey_page.id}"].present? && raw_data["page_#{survey_page.id}"]["started_at"].present?
      result["started_at"] = Time.zone.now if result["started_at"].blank?

      result["page_number"] = survey_page.page_number
      result["title"] = survey_page.title

      result["items"] = {}

      survey_page.survey_items.in_order.each do |item|
        next unless item.full_display?(all_answer_data)

        add_final_item(result["items"], item)
      end

      result
    end

    def answer_value(value, item)
      case item.survey_itemable.question_type
      when SurveyQuestionType::Encrypted.new
        EncryptionService.encrypt(value)
      else
        value
      end
    end

    def final_question_hash(item)
      base_itemable_data(item).merge!({
        "label" => item.survey_itemable.label,
        "question_type" => item.survey_itemable.question_type.to_s,
        "value" => answer_value(all_answer_data["question_#{item.survey_itemable.id}"], item),
        "question_id" => item.survey_itemable.id,
      })
    end

    def base_section_hash(item)
      base_itemable_data(item).merge!({
        "title" => item.survey_itemable.title,
        "items" => {}
      })
    end

    def base_itemable_data(item)
      {
        "item_number" => item.item_number,
        "item_id" => item.id,
        "survey_type" => survey.survey_type
      }
    end

    def add_final_item(hash, item)
      return unless item.full_display?(all_answer_data)

      case item.survey_itemable_type
      when "SurveyQuestion"
        hash["question_#{item.survey_itemable.id}"] = final_question_hash(item)


        if item.survey_itemable.question_type.agreement?
          hash["question_#{item.survey_itemable.id}"]["agree_text"] = item.survey_itemable.agree_text
        end
      when "SurveySection"
        hash["section_#{item.survey_itemable.id}"] = base_section_hash(item)

        item.survey_itemable.survey_items.each do |sub_item|
          add_final_item(hash["section_#{item.survey_itemable.id}"]["items"], sub_item)
        end
      end
    end
  end
end
