class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    # Redirect the user to the previous page on succesful login
    safe_redirect_path(new_user_session_path)
  end

  def after_sign_out_path_for(resource)
    # Same as for after_sign_in_path_for
    safe_redirect_path(destroy_user_session_path)
  end

  def safe_redirect_path(exclude)
    begin
      if params[:redirect_to].present?
        p = URI(params[:redirect_to]).path
        return p unless p == exclude
      end

      root_path
    rescue
    end
  end
end
