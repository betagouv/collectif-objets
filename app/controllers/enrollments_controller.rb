# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  Enrollment = Struct.new(:name, :role, :email, :phone, :commune, :notes)

  before_action :set_enrollment

  def new
    @enrollment.email = current_user&.email
    @enrollment.commune = current_user&.commune&.nom
  end

  def create
    res = Co::Airtable::CreateEnrollmentRecord.new(@enrollment).perform
    puts "res is #{@enrollment.to_h}"
    return redirect_to enrollment_success_path if res

    flash[:alert] = "Une erreur s'est produite, veuillez vérifiez vos
      informations et réessayer. Contactez-nous si le problème persiste."
    redirect_to inscription_path(enrollment: @enrollment.to_h)
  end

  protected

  def set_enrollment
    @enrollment = Enrollment.new(*enrollment_params.to_h.values_at(*Enrollment.members))
  end

  def enrollment_params
    params.permit(enrollment: %i[name role email phone commune notes])[:enrollment]
  end
end
