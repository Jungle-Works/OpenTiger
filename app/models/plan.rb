# == Schema Information
#
# Table name: plans
#
#  id                :integer          not null, primary key
#  name              :string(255)      default("")
#  description       :string(255)      default("")
#  plan_type         :integer          default(0)
#  billing_frequency :integer          default(0)
#  price             :decimal(8, 2)
#  currency          :string(255)      default("$")
#  per_day_cost      :decimal(8, 2)
#  months            :integer          default(0)
#  is_enabled        :boolean          default(TRUE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Plan < ApplicationRecord

    def self.create_plans
        unless all.present?
            Plan.create( name: "Trial", description: "Trial", plan_type: 0, billing_frequency: 0, price: 0, discounted_price: 0, per_day_cost: 0.0, months: 0, plan_code: "trial", content: "")
            Plan.create( name: "Free forever", description: "Free forever", plan_type: 0, billing_frequency: 0, discounted_price: 0, price: 0, per_day_cost: 0.0, months: 1, plan_code: "free", :content => "{\"image_name\":\"free\",\"price\":\"0.00\",\"discounted_price\":\"0.00\",\"plan_detail\":[\"Ordering Website\",\"Admin \\u0026 Merchant Panel\",\"Unlimited Orders\",\"24/7 Support\"]}")
            Plan.create( name: "Growth", description: "Growth", plan_type: 1, billing_frequency: 1, price: 49.00, discounted_price: 49.00, per_day_cost: 0.0, months: 1, plan_code: "paid", :content => "{\"image_name\":\"growth\",\"price\":\"49.00\",\"discounted_price\":\"49.00\",\"plan_detail\":[\"Everything in the Free Plan\",\"Use your own domain\",\"Landing Page\"]}")
            Plan.create( name: "Premium", description: "Premium", plan_type: 2, billing_frequency: 1, price: 199.00, discounted_price: 199.00, per_day_cost: 0.0, months: 1, plan_code: "paid", :content => "{\"image_name\":\"premium\",\"price\":\"199.00\",\"discounted_price\":\"199.00\",\"plan_detail\":[\"Everything in the Growth Plan\",\"Branded Apps *(IOS and Android)*\"]}")
            Plan.create( name: "Growth", description: "Growth", plan_type: 1, billing_frequency: 2, price: 8.33, discounted_price: 29.00, per_day_cost: 0.0, months: 12, plan_code: "paid", :content => "{\"image_name\":\"growth\",\"price\":\"29.00\",\"discounted_price\":\"8.33\",\"plan_detail\":[\"Everything in the Free Plan\",\"Use your own domain\",\"Landing Page\"]}")
            Plan.create( name: "Premium", description: "Premium", plan_type: 2, billing_frequency: 2, price: 149.00, discounted_price: 149.00, per_day_cost: 0.0, months: 12, plan_code: "paid", :content => "{\"image_name\":\"premium\",\"price\":\"149.00\",\"discounted_price\":\"149.00\",\"plan_detail\":[\"Everything in the Growth Plan\",\"Branded Apps *(IOS and Android)*\"]}")
        end
    end

    def self.calculate_amount(plan_hsh, plan_purchase_day)
        if plan_hsh["billing_frequency"] == 1
            plan_used_days = (plan_purchase_day.end_of_month - plan_purchase_day).to_i + 1 #Add 1 to add current day
            # per_day_cost = price/plan_purchase_day.end_of_month.day
            final_amount = plan_used_days * calculate_per_day_cost(plan_hsh)
        else
            return plan_hsh["amount"] * plan_hsh["months"]
        end
    end

    def self.calculate_per_day_cost(plan_hsh)
        if plan_hsh["billing_frequency"] == 1
            return (plan_hsh["amount"].to_f/30) * plan_hsh["months"]        
        elsif plan_hsh["billing_frequency"] == 2
            return (plan_hsh["amount"].to_f/30.5) * plan_hsh["months"]      
        else
            return  0
        end
    end

    def self.change_plan_hsh(plan)
        hsh = HashWithIndifferentAccess.new
        hsh[:id] = plan["plan_id"]
        hsh[:name] = plan["name"]
        hsh[:description] = plan["description"]
        hsh[:amount] = plan["amount"]
        hsh[:discounted_price] = plan["amount"].round(2)
        hsh[:display_amount] = plan["display_amount"]
        hsh[:months] = plan["months"]
        hsh[:billing_frequency] = plan["billing_frequency"]
        hsh[:plan_code] = Plan.fetch_plan_code(plan["plan_id"])
        hsh[:plan_type] = plan["plan_type"]
        return hsh
    end

    def self.fetch_required_plans(plans,plan_ids)
        monthly_plans_array = []
        plans.each do |p|
            if plan_ids.include?(p["plan_id"])
                hsh = HashWithIndifferentAccess.new
                hsh[:id] = p["plan_id"]
                hsh[:name] = p["name"]
                hsh[:description] = p["description"]
                hsh[:amount] = p["amount"]
                hsh[:discounted_price] = p["amount"].round(2)
                hsh[:display_amount] = p["display_amount"]
                hsh[:months] = p["months"]
                hsh[:billing_frequency] = p["billing_frequency"]
                hsh[:plan_code] = Plan.fetch_plan_code(p["plan_id"])
                hsh[:content] = Plan.fetch_content(p["plan_id"])
                hsh[:plan_type] = p["plan_type"]
                monthly_plans_array.push hsh
            end
        end
        return monthly_plans_array
    end

    def self.fetch_plan_code(plan_id)
        case plan_id
        when 1
            "trial"
        when 8
            "free"
        when 9,10,11,12
            "paid"
        else
            ""
        end 
    end

    def self.fetch_content(plan_id)
        case plan_id
        when 8
            "{\"image_name\":\"free\",\"price\":\"0.00\",\"discounted_price\":\"0.00\",\"plan_detail\":[\"Ordering Website\",\"Admin \\u0026 Merchant Panel\",\"Unlimited Orders\",\"24/7 Support\"]}"
        when 9
            "{\"image_name\":\"growth\",\"price\":\"49.00\",\"discounted_price\":\"49.00\",\"plan_detail\":[\"Everything in the Free Plan\",\"Use your own domain\",\"Landing Page\",\"Logo Change\",\"Premium Theme\"]}"
        when 10
            "{\"image_name\":\"premium\",\"price\":\"199.00\",\"discounted_price\":\"199.00\",\"plan_detail\":[\"Everything in the Growth Plan\",\"Branded Apps *(IOS and Android)*\"]}"
        when 11
            "{\"image_name\":\"growth\",\"price\":\"29.00\",\"discounted_price\":\"8.33\",\"plan_detail\":[\"Everything in the Free Plan\",\"Use your own domain\",\"Landing Page\",\"Logo Change\",\"Premium Theme\"]}"
        when 12
            "{\"image_name\":\"premium\",\"price\":\"149.00\",\"discounted_price\":\"149.00\",\"plan_detail\":[\"Everything in the Growth Plan\",\"Branded Apps *(IOS and Android)*\"]}"
        else
            "{}"
        end 
    end
    
end
