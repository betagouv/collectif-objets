# frozen_string_literal: true

module Admin
  class CommentsController < BaseController
    def create
      comment = AdminComment.new(**comment_params, author: current_admin_user)
      if comment.save
        redirect_to [:admin, comment.resource], notice: "commentaire créé !"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      comment = AdminComment.find(params[:id])
      if comment.destroy
        redirect_to [:admin, comment.resource], notice: "commentaire supprimé !"
      else
        redirect_to [:admin, comment.resource], alert: "impossible de supprimer le commentaire"
      end
    end

    private

    def comment_params
      params.require(:comment).permit(:body, :resource_type, :resource_id)
    end
  end
end
