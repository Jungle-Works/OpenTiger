module CustomLandingPage
  module LandingPageStoreDB

    class LandingPage < ApplicationRecord; end
    class LandingPageVersion < ApplicationRecord; end

    module_function

    #
    # Common methods with the static CLP store implementation
    #

    def released_version(cid)
      enabled, released_version = LandingPage.where(community_id: cid)
                                  .pluck(:enabled, :released_version)
                                  .first
      if !enabled
        raise LandingPageConfigurationError.new("Landing page not enabled. community_id: #{cid}.")
      elsif released_version.nil?
        raise LandingPageConfigurationError.new("Landing page version not specified.")
      end

      released_version
    end

    def get_current_released_version(cid)
      return LandingPage.where(community_id: cid).last.released_version
    end
    
    def get_versions
      return LandingPageVersion.all
    end

    def load_structure(cid, version)
      content = LandingPageVersion.where(community_id: cid, version: version)
      .pluck(:content)
      .first
      if content.blank?
        raise LandingPageContentNotFound.new("Content missing. community_id: #{cid}, version: #{version}.")
      end
      
      LandingPageStoreDefaults.add_defaults(
        JSON.parse(content))
      end
      
      def enabled?(cid)
        if RequestStore.store.key?(:clp_enabled)
          RequestStore.store[:clp_enabled]
        else
          RequestStore.store[:clp_enabled] = _enabled?(cid)
        end
      end
      
      def check_if_landing_page_exist(cid)
        return true if LandingPage.where(community_id: cid).present?
        return false
      end
      
      def check_communities_without_landing_page
        not_active_ids = Community.ids - LandingPage.all.pluck(:community_id).uniq
        # return true if LandingPage.where(community_id: cid).present?
        # return false
      end
      
      def check_if_version_exist(cid,version)
        return true if LandingPageVersion.where(community_id: cid, version: version).present?
        return false
      end
      
      def disable_landing_page(cid)
        LandingPage.where(community_id: cid).update(:enabled => false)
      end
      
      def enable_landing_page(cid)
        LandingPage.where(community_id: cid).update(:enabled => true)
      end
      #
      # Database specific methods
      #
      
      
      
      def create_landing_page!(cid)
        LandingPage.create(community_id: cid)
      end
      
      def create_version!(cid, version_number, content)
        LandingPageVersion.create(community_id: cid, version: version_number, content: content)
      end
    
      def update_and_release_version!(cid,current_version, content)
        lp = LandingPage.where(community_id: cid).first
        last_version = LandingPageVersion.where(community_id: cid).order("version").last.version

        current_released_version = LandingPageVersion.where(community_id: cid, version: current_version).last
        current_released_version.released = Time.now
        current_released_version.version = last_version + 1
        current_released_version.content = content
        current_released_version.save!

        lp.released_version = last_version + 1
        lp.save!
        lp
      end

      def update_version_number!(cid)
        lp = LandingPage.where(community_id: cid).first
        last_version = LandingPageVersion.where(community_id: cid).order("version").last.version
        current_version = get_current_released_version(cid)
        current_released_version = LandingPageVersion.where(community_id: cid, version: current_version).last
        current_released_version.released = Time.now
        current_released_version.version = last_version + 1
        # current_released_version.content = content
        current_released_version.save!

        lp.released_version = last_version + 1
        lp.save!
        lp
      end
      
    def update_version!(cid, version_number, content)
        version = LandingPageVersion.where(community_id: cid, version: version_number).first
      unless version
        raise LandingPageNotFound.new("Version not found for community_id: #{cid} and version: #{version_number}.")
      end

      version.content = content
      version.save!
      # lp = LandingPageVersion.where(community_id: cid, version: version_number).content
    end

    def release_version!(cid, version_number)
      LandingPage.transaction do
        lp = LandingPage.where(community_id: cid).first

        unless lp
          LandingPageNotFound.new("No landing page created for community_id: #{cid}.")
        end

        version = LandingPageVersion.where(community_id: cid, version: version_number).first

        unless version
          LandingPageNotFound.new("No landing page version for community_id: #{cid}, version: #{version_number}.")
        end

        version.released = Time.now
        lp.released_version = version.version
        lp.enabled = 1

        version.save!
        lp.save!
        lp
      end
    end

    # private

    def _enabled?(cid)
      enabled, released_version = LandingPage
                                  .where(community_id: cid)
                                  .pluck(:enabled, :released_version)
                                  .first
      !!(enabled && released_version)
    end
  end
end
