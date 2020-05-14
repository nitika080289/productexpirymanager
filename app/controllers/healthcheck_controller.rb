class HealthcheckController < ApplicationController
  def check
    render nothing: true, status: 200
  end
end
