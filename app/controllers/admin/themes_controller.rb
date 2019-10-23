class Admin::ThemesController < Admin::AdminBaseController


    def index
        # Theme.create_themes unless Theme.all.present?
        make_onboarding_popup
        @available_themes = Theme.all
        @selected_left_navi_link = "themes"
        

    end
    
    def change_theme
        selected_theme = Theme.find_by_id(params[:id])
        if @current_theme.id != params[:id] && selected_theme.present?
            @current_theme.update(enabled: false)
            if @current_community.community_themes.find_by_theme_id(params[:id]).present?
                @current_community.community_themes.find_by_theme_id(params[:id]).update(enabled: true)
                @current_theme = @current_community.community_themes.find_by_theme_id(params[:id])
            else
                @current_theme = @current_community.community_themes.create(theme_id: selected_theme.id, content: selected_theme.content, enabled: true, released_at: Time.now)        
            end
        end
        state_changed = Admin::OnboardingWizard.new(@current_community.id)
        .update_from_event(:theme_updated, {:updated=> true})
        if state_changed
            flash[:show_onboarding_popup] = true
        end
        redirect_to admin_themes_path
    end

    def preview
        @selected_theme = Theme.find_by_id(params[:id])
    end

end

