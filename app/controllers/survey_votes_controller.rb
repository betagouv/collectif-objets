# frozen_string_literal: true

class SurveyVotesController < ApplicationController
  before_action :set_commune, :validate_survey_exists, :validate_commune_has_not_voted, only: [:new]

  def new
    validate_commune_has_not_voted
    validate_survey_exists

    @survey_vote = SurveyVote.new(commune: @commune, survey: params[:survey], reason: params[:reason])
  end

  def create
    @survey_vote = SurveyVote.new(survey_vote_params)
    @commune = @survey_vote.commune
    if @survey_vote.save
      redirect_to @commune, notice: "Merci pour votre réponse !"
    else
      @commune = @survey_vote.commune
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_commune
    @commune = Commune.find(params[:commune_id])
  end

  def validate_survey_exists
    return true if params[:survey] == "campaign_inactive"

    redirect_to @commune, alert: "ce sondage n'existe pas"
  end

  def validate_commune_has_not_voted
    return true if @commune.survey_votes.where(survey: "campaign_inactive").empty?

    redirect_to(@commune, alert: "votre commune #{@commune} a déjà répondu à ce sondage")
  end

  def survey_vote_params
    params.require(:survey_vote).permit(:commune_id, :survey, :reason, :additional_info)
  end
end
