# This controller is parent for all controllers handling the admin area functions

class Admin::AdminBaseController < ApplicationController

  before_action :ensure_is_admin
  before_action :get_available_themes
  # before_action :new_plan_hsh

  #Allow admin to access admin panel before email confirmation
  skip_before_action :cannot_access_without_confirmation

end
