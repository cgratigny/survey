class HummingbirdSurvey::SurveySectionsController < HummingbirdSurvey::BaseController
  before_action :find_survey

  before_action :build_survey_section, only: [:new, :create]
  before_action :find_survey_section, only: [:show, :edit, :update, :destroy, :add_question, :add_note, :add_section]
  before_action :authorize_single, except: :index

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @survey_section.update(survey_section_params)
        format.html { redirect_to edit_survey_path(@survey), notice: 'Survey section was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_section }
      else
        format.html { render :edit }
        format.json { render json: @survey_section.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_section.destroy
    respond_to do |format|
      format.html { redirect_to edit_survey_path(@survey), notice: 'Survey section was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_question
    question = SurveyQuestion.create!
    item = SurveyItem.create!(survey_itemable: question, parent: @survey_section, item_number: @survey_section.survey_items.maximum(:item_number).to_i + 1)

    redirect_to edit_survey_path(@survey), notice: 'Survey question was successfully added.'
  end

  def add_note
    note = SurveyNote.create!
    item = SurveyItem.create!(survey_itemable: note, parent: @survey_section, item_number: @survey_section.survey_items.maximum(:item_number).to_i + 1)

    redirect_to edit_survey_path(@survey), notice: 'Survey note was successfully added.'
  end

  def add_section
    section = SurveySection.create!
    item = SurveyItem.create!(survey_itemable: section, parent: @survey_section, item_number: @survey_section.survey_items.maximum(:item_number).to_i + 1)

    redirect_to edit_survey_path(@survey), notice: 'Survey section was successfully added.'
  end

  private

  def find_survey
    @survey = Survey.find(params[:survey_id])
  end

  def find_survey_section
    @survey_section = SurveySection.find(params[:id])
    @survey_item = @survey_section.survey_item
  end

  def authorize_single
    authorize @survey_section
  end

  def survey_section_params
    params[:survey_section].present? ? params.require(:survey_section).permit(:title) : {}
  end
end
