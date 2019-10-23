# == Schema Information
#
# Table name: themes
#
#  id             :integer          not null, primary key
#  title          :string(255)      default("")
#  description    :string(255)      default("")
#  content        :text(16777215)   not null
#  is_paid        :boolean          default("free")
#  price_in_cents :integer          default(0)
#  price_currency :string(255)      default("")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Theme < ApplicationRecord

    has_many :community_themes
    
    PAYMENTSTATUS = {
        FREE = 'free'.freeze => false,
        PAID = 'paid'.freeze => true
      }
      enum is_paid: PAYMENTSTATUS

      def self.create_themes
        unless all.present?
          create(title: "Basic", description: "This theme is for user with lite plan.", content: 
          '{
            "theme_unique_identifier": "basic-theme",
            "screenshots": [
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/nrvg1564660326343-Screenshot20190801at5.20.18PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/ADhU1564660574234-Screenshot20190801at5tn.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/ishv1564471705262-Screenshot20190730at12.27.08PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/qeca1564471907525-Screenshot20190730at12tn4.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/5lpq1564471611088-Screenshot20190730at12.24.39PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/rUHd1564471884971-Screenshot20190730at12tn3.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/xbQL1564471624992-Screenshot20190730at12.25.15PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/rweu1564471915439-Screenshot20190730at12tn.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/b15U1564471679946-Screenshot20190730at12.27.42PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/L5Fv1564471876497-Screenshot20190730at12tn2.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/1qaw1564471652190-Screenshot20190730at12.28.31PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/OxLp1564471897791-Screenshot20190730at12tn5.jpg"
              }
            ]
          }', is_paid: false, price_in_cents: 0, price_currency: "")
          create(title: "Lite", description: "This theme is for user with basic plan.", content: '{
            "theme_unique_identifier": "go-theme",
            "screenshots": [
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/X5mT1564660315741-Screenshot20190801at4.56.07PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/lXGJ1564660566972-Screenshot20190801at4tn.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/ishv1564471705262-Screenshot20190730at12.27.08PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/qeca1564471907525-Screenshot20190730at12tn4.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/5lpq1564471611088-Screenshot20190730at12.24.39PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/rUHd1564471884971-Screenshot20190730at12tn3.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/xbQL1564471624992-Screenshot20190730at12.25.15PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/rweu1564471915439-Screenshot20190730at12tn.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/b15U1564471679946-Screenshot20190730at12.27.42PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/L5Fv1564471876497-Screenshot20190730at12tn2.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/1qaw1564471652190-Screenshot20190730at12.28.31PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/OxLp1564471897791-Screenshot20190730at12tn5.jpg"
              }
            ]
          }', is_paid: false, price_in_cents: 0, price_currency: "")
          create(title: "Premium", description: "This theme is for user with advanced plan.", content: '{
            "theme_unique_identifier": "flex-theme",
            "screenshots": [
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/nrvg1564660326343-Screenshot20190801at5.20.18PM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/ADhU1564660574234-Screenshot20190801at5tn.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/HMHH1564470508637-Screenshot20190730at11.21.37AM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/0PT21564471087532-Screenshot20190730at11tn12.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/UJm71564470640218-Screenshot20190730at11.39.59AM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/TEke1564470957895-Screenshot20190730at11tn4.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/HqlN1564470713078-Screenshot20190730at11.42.44AM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/9heU1564470966046-Screenshot20190730at11tn5.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/mQho1564470748624-Screenshot20190730at11.44.49AM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/WcUY1564470979116-Screenshot20190730at11tn6.jpg"
              },
              {
                "big": "https://yelodotred.s3.amazonaws.com/task_images/vXk21564470783897-Screenshot20190730at11.48.54AM.png",
                "thumb": "https://yelodotred.s3.amazonaws.com/task_images/QFxQ1564470922132-Screenshot20190730at11tn2.jpg"
              }
            ]
          }', is_paid: true, price_in_cents: 0, price_currency: "")
        end
      end
      
end
