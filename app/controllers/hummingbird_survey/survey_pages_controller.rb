class HummingbirdSurvey::SurveyPagesController < HummingbirdSurvey::BaseController
  before_action :find_survey

  before_action :build_survey_page, only: [:new, :create]
  before_action :find_survey_page, only: [:show, :edit, :update, :destroy, :add_question, :add_note, :add_section]
  before_action :authorize_single

  def index
  end

  def show
  end

  def new
  end

  def create
    respond_to do |format|
      if @survey_page.save
        format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey page was successfully created.' }
        format.json { render :show, status: :created, location: @survey_page }
      else
        format.html { render :new }
        format.json { render json: @survey_page.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @survey_page.update(survey_page_params)
        format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey page was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_page }
      else
        format.html { render :edit }
        format.json { render json: @survey_page.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_page.destroy
    respond_to do |format|
      format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey page was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_question
    question = SurveyQuestion.create!
    item = SurveyItem.create!(survey_itemable: question, parent: @survey_page, item_number: @survey_page.survey_items.maximum(:item_number).to_i + 1)

    redirect_to edit_staff_survey_path(@survey), notice: 'Survey question was successfully added.'
  end

  def add_note
    note = SurveyNote.create!
    item = SurveyItem.create!(survey_itemable: note, parent: @survey_page, item_number: @survey_page.survey_items.maximum(:item_number).to_i + 1)

    redirect_to edit_staff_survey_path(@survey), notice: 'Survey note was successfully added.'
  end

  def add_section
    section = SurveySection.create!
    item = SurveyItem.create!(survey_itemable: section, parent: @survey_page, item_number: @survey_page.survey_items.maximum(:item_number).to_i + 1)

    redirect_to edit_staff_survey_section_path(@survey, section), notice: 'Survey section was successfully added.'
  end

  private

  def find_survey
    @survey = Survey.find(params[:survey_id])
  end

  def build_survey_page
    @survey_page = SurveyPage.new(survey_page_params)
    @survey_page.survey = @survey
  end

  def find_survey_page
    @survey_page = SurveyPage.find(params[:id])
  end

  def authorize_single
    authorize @survey_page
  end

  def survey_page_params
    params[:survey_page].present? ? params.require(:survey_page).permit(:survey_id, :title, :page_number) : {}
  end
end
