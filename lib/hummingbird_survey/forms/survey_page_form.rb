module HummingbirdSurvey::SurveyPageForm
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

  def parse_attributes(params)
    target_params = params["survey_page_form"].permit!
    questions.each do |question|
      send("#{question.qkey}=", target_params[question.qkey])
    end
  end

  def attributes=(params)
    parse_attributes(params)
  end

  def submit(params, should_validate = true)
    parse_attributes(params)
    save(should_validate)
  end

  def save(should_validate = true)
    if !should_validate || valid?
      target_page_data = build_final_page_data
      raw_data["page_#{survey_page.id}"] = target_page_data
      survey.set_surveyed_data_for!(surveyed, raw_data, request)
      surveyed.reload
      true
    else
      false
    end
  end

  private

  def required_questions_presence
    required_questions.each do |question|
      if question.question_type.checkbox?
        errors.add(question.qkey.to_sym, "is required") if question.actually_required?(all_answer_data) && send(question.qkey.to_sym).to_s != "1"
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

  def add_final_item(hash, item)
    case item.survey_itemable_type
    when "SurveyQuestion"
      hash["question_#{item.survey_itemable.id}"] = {
        "item_number" => item.item_number,
        "label" => item.survey_itemable.label,
        "value" => all_answer_data["question_#{item.survey_itemable.id}"]
      }
    when "SurveySection"
      hash["section_#{item.survey_itemable.id}"] = {
        "item_number" => item.item_number,
        "title" => item.survey_itemable.title,
        "items" => {}
      }

      item.survey_itemable.survey_items.each do |sub_item|
        add_final_item(hash["section_#{item.survey_itemable.id}"]["items"], sub_item)
      end
    end
  end
end
