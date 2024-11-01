class Api::V1::SystemsController < ApplicationController
  before_action :auth_from_token

  # GET /api/v1/systems
  def index
    @systems = System.joins(:roles).distinct
    render json: @systems,
      only: [:id, :name],
      include: [roles: { only: [:id, :name] }]
  end

end