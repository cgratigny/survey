class HummingbirdSurvey::SurveyNotesController < HummingbirdSurvey::BaseController
  before_action :find_survey

  before_action :find_survey_note, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @survey_note.update(survey_note_params)
        format.html { redirect_to edit_survey_path(@survey), notice: 'Survey note was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_note }
      else
        format.html { render :edit }
        format.json { render json: @survey_note.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_note.destroy
    respond_to do |format|
      format.html { redirect_to edit_survey_path(@survey), notice: 'Survey note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def find_survey
    @survey = Survey.find(params[:survey_id])
  end

  def find_survey_note
    @survey_note = SurveyNote.find(params[:id])
    @survey_item = @survey_note.survey_item
  end

  def authorize_single
    authorize @survey_note
  end

  def survey_note_params
    params[:survey_note].present? ? params.require(:survey_note).permit(:content) : {}
  end
end
