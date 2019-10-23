(function(module){
    var icons = [
        {
          "text": "3d-drawing-3",
          "value": "3d-drawing-3"
        },
        {
          "text": "account-circle-1",
          "value": "account-circle-1"
        },
        {
          "text": "account-circle-2",
          "value": "account-circle-2"
        },
        {
          "text": "account-dollar",
          "value": "account-dollar"
        },
        {
          "text": "account-favorite",
          "value": "account-favorite"
        },
        {
          "text": "account-find-1",
          "value": "account-find-1"
        },
        {
          "text": "account-find-2",
          "value": "account-find-2"
        },
        {
          "text": "account-flag",
          "value": "account-flag"
        },
        {
          "text": "account-group-1",
          "value": "account-group-1"
        },
        {
          "text": "account-group-2",
          "value": "account-group-2"
        },
        {
          "text": "account-group-3",
          "value": "account-group-3"
        },
        {
          "text": "account-group-4",
          "value": "account-group-4"
        },
        {
          "text": "account-group-5",
          "value": "account-group-5"
        },
        {
          "text": "account-group-circle",
          "value": "account-group-circle"
        },
        {
          "text": "account-home-1",
          "value": "account-home-1"
        },
        {
          "text": "account-square",
          "value": "account-square"
        },
        {
          "text": "account-star",
          "value": "account-star"
        },
        {
          "text": "accounting-coins",
          "value": "accounting-coins"
        },
        {
          "text": "accounting-coins-bill",
          "value": "accounting-coins-bill"
        },
        {
          "text": "agriculture-machine-tractor",
          "value": "agriculture-machine-tractor"
        },
        {
          "text": "airplane-1",
          "value": "airplane-1"
        },
        {
          "text": "airplane-departure",
          "value": "airplane-departure"
        },
        {
          "text": "alarm-clock",
          "value": "alarm-clock"
        },
        {
          "text": "animal-hands",
          "value": "animal-hands"
        },
        {
          "text": "armchair-1",
          "value": "armchair-1"
        },
        {
          "text": "armchair-2",
          "value": "armchair-2"
        },
        {
          "text": "arrows",
          "value": "arrows"
        },
        {
          "text": "artist",
          "value": "artist"
        },
        {
          "text": "atomic-bomb",
          "value": "atomic-bomb"
        },
        {
          "text": "auction",
          "value": "auction"
        },
        {
          "text": "award-star-head",
          "value": "award-star-head"
        },
        {
          "text": "baggage",
          "value": "baggage"
        },
        {
          "text": "baggage-drop-off",
          "value": "baggage-drop-off"
        },
        {
          "text": "baby-bed",
          "value": "baby-bed"
        },
        {
          "text": "baby-stroller",
          "value": "baby-stroller"
        },
        {
          "text": "badge-1",
          "value": "badge-1"
        },
        {
          "text": "badge-6",
          "value": "badge-6"
        },
        {
          "text": "badge-like-1",
          "value": "badge-like-1"
        },
        {
          "text": "badge-number-one-1",
          "value": "badge-number-one-1"
        },
        {
          "text": "balloon",
          "value": "balloon"
        },
        {
          "text": "bank-notes-3",
          "value": "bank-notes-3"
        },
        {
          "text": "barn",
          "value": "barn"
        },
        {
          "text": "basket-1",
          "value": "basket-1"
        },
        {
          "text": "basket-remove",
          "value": "basket-remove"
        },
        {
          "text": "beach",
          "value": "beach"
        },
        {
          "text": "bicycle-cruiser",
          "value": "bicycle-cruiser"
        },
        {
          "text": "bicycle-mountain",
          "value": "bicycle-mountain"
        },
        {
          "text": "binocular",
          "value": "binocular"
        },
        {
          "text": "binoculars",
          "value": "binoculars"
        },
        {
          "text": "birthday-cake",
          "value": "birthday-cake"
        },
        {
          "text": "boat-2",
          "value": "boat-2"
        },
        {
          "text": "boat-sail-3",
          "value": "boat-sail-3"
        },
        {
          "text": "boat-steering-wheel",
          "value": "boat-steering-wheel"
        },
        {
          "text": "book-view",
          "value": "book-view"
        },
        {
          "text": "box-handle-1",
          "value": "box-handle-1"
        },
        {
          "text": "box-handle-2",
          "value": "box-handle-2"
        },
        {
          "text": "box-storehouse",
          "value": "box-storehouse"
        },
        {
          "text": "broccoli",
          "value": "broccoli"
        },
        {
          "text": "bubble-chat-1",
          "value": "bubble-chat-1"
        },
        {
          "text": "bubble-chat-2",
          "value": "bubble-chat-2"
        },
        {
          "text": "bubble-chat-heart-2",
          "value": "bubble-chat-heart-2"
        },
        {
          "text": "bubble-chat-question-1",
          "value": "bubble-chat-question-1"
        },
        {
          "text": "bubble-chat-text-1",
          "value": "bubble-chat-text-1"
        },
        {
          "text": "bubble-thought",
          "value": "bubble-thought"
        },
        {
          "text": "building-1",
          "value": "building-1"
        },
        {
          "text": "building-12",
          "value": "building-12"
        },
        {
          "text": "building-17",
          "value": "building-17"
        },
        {
          "text": "building-18",
          "value": "building-18"
        },
        {
          "text": "building-19",
          "value": "building-19"
        },
        {
          "text": "business-bag-cash",
          "value": "business-bag-cash"
        },
        {
          "text": "business-check",
          "value": "business-check"
        },
        {
          "text": "business-deal-cash-exchange",
          "value": "business-deal-cash-exchange"
        },
        {
          "text": "business-deal-handshake",
          "value": "business-deal-handshake"
        },
        {
          "text": "business-female-money",
          "value": "business-female-money"
        },
        {
          "text": "business-hierarchy",
          "value": "business-hierarchy"
        },
        {
          "text": "business-male-money",
          "value": "business-male-money"
        },
        {
          "text": "business-man-2",
          "value": "business-man-2"
        },
        {
          "text": "business-man-3",
          "value": "business-man-3"
        },
        {
          "text": "business-man-speech",
          "value": "business-man-speech"
        },
        {
          "text": "business-maze",
          "value": "business-maze"
        },
        {
          "text": "business-statistics-3",
          "value": "business-statistics-3"
        },
        {
          "text": "business-strategy",
          "value": "business-strategy"
        },
        {
          "text": "business-trade",
          "value": "business-trade"
        },
        {
          "text": "button-play",
          "value": "button-play"
        },
        {
          "text": "cake-birthday",
          "value": "cake-birthday"
        },
        {
          "text": "cake-slice",
          "value": "cake-slice"
        },
        {
          "text": "calendar-2",
          "value": "calendar-2"
        },
        {
          "text": "calendar-3",
          "value": "calendar-3"
        },
        {
          "text": "calendar-cash-1",
          "value": "calendar-cash-1"
        },
        {
          "text": "calendar-check",
          "value": "calendar-check"
        },
        {
          "text": "calendar-check-1",
          "value": "calendar-check-1"
        },
        {
          "text": "calendar-check-1-v3",
          "value": "calendar-check-1-v3"
        },
        {
          "text": "calendar-edit",
          "value": "calendar-edit"
        },
        {
          "text": "calendar-heart-1",
          "value": "calendar-heart-1"
        },
        {
          "text": "calendar-lock-1",
          "value": "calendar-lock-1"
        },
        {
          "text": "calendar-plane",
          "value": "calendar-plane"
        },
        {
          "text": "camera-1",
          "value": "camera-1"
        },
        {
          "text": "camera-1-light",
          "value": "camera-1-light"
        },
        {
          "text": "camera-2",
          "value": "camera-2"
        },
        {
          "text": "camera-lens-1",
          "value": "camera-lens-1"
        },
        {
          "text": "camera-user",
          "value": "camera-user"
        },
        {
          "text": "canoe",
          "value": "canoe"
        },
        {
          "text": "canoe-1",
          "value": "canoe-1"
        },
        {
          "text": "canoe-2",
          "value": "canoe-2"
        },
        {
          "text": "canoe-3",
          "value": "canoe-3"
        },
        {
          "text": "car-2",
          "value": "car-2"
        },
        {
          "text": "car-10",
          "value": "car-10"
        },
        {
          "text": "car-actions-check-1",
          "value": "car-actions-check-1"
        },
        {
          "text": "car-actions-search-1",
          "value": "car-actions-search-1"
        },
        {
          "text": "car-key",
          "value": "car-key"
        },
        {
          "text": "cash-idea",
          "value": "cash-idea"
        },
        {
          "text": "cash-payment-bag-1-light",
          "value": "cash-payment-bag-1-light"
        },
        {
          "text": "cash-payment-bag-1-regular",
          "value": "cash-payment-bag-1-regular"
        },
        {
          "text": "cash-payment-bag-1-regular-2",
          "value": "cash-payment-bag-1-regular-2"
        },
        {
          "text": "cash-payment-bag-regular",
          "value": "cash-payment-bag-regular"
        },
        {
          "text": "cash-payment-bill-1",
          "value": "cash-payment-bill-1"
        },
        {
          "text": "cash-payment-bill-2",
          "value": "cash-payment-bill-2"
        },
        {
          "text": "cash-payment-bill-3",
          "value": "cash-payment-bill-3"
        },
        {
          "text": "cash-payment-bill-4",
          "value": "cash-payment-bill-4"
        },
        {
          "text": "cash-protect",
          "value": "cash-protect"
        },
        {
          "text": "chat-bubble-picture-2",
          "value": "chat-bubble-picture-2"
        },
        {
          "text": "chat-double-bubble-1",
          "value": "chat-double-bubble-1"
        },
        {
          "text": "chat-double-bubble-3",
          "value": "chat-double-bubble-3"
        },
        {
          "text": "chat-double-bubble-4",
          "value": "chat-double-bubble-4"
        },
        {
          "text": "check-2",
          "value": "check-2"
        },
        {
          "text": "check-badge",
          "value": "check-badge"
        },
        {
          "text": "check-box-1",
          "value": "check-box-1"
        },
        {
          "text": "check-box-2",
          "value": "check-box-2"
        },
        {
          "text": "check-circle-1",
          "value": "check-circle-1"
        },
        {
          "text": "check-circle-2",
          "value": "check-circle-2"
        },
        {
          "text": "check-shield",
          "value": "check-shield"
        },
        {
          "text": "checklist-pen",
          "value": "checklist-pen"
        },
        {
          "text": "chef-hat",
          "value": "chef-hat"
        },
        {
          "text": "circus-tent-2",
          "value": "circus-tent-2"
        },
        {
          "text": "clipboard-add",
          "value": "clipboard-add"
        },
        {
          "text": "clipboard-check",
          "value": "clipboard-check"
        },
        {
          "text": "clock-2",
          "value": "clock-2"
        },
        {
          "text": "close",
          "value": "close"
        },
        {
          "text": "cloud-lock",
          "value": "cloud-lock"
        },
        {
          "text": "cloud-mobile-upload",
          "value": "cloud-mobile-upload"
        },
        {
          "text": "coffee-cup-1",
          "value": "coffee-cup-1"
        },
        {
          "text": "coffee-cup-2",
          "value": "coffee-cup-2"
        },
        {
          "text": "cog",
          "value": "cog"
        },
        {
          "text": "cog-double-1",
          "value": "cog-double-1"
        },
        {
          "text": "coin-receive",
          "value": "coin-receive"
        },
        {
          "text": "coins-receive",
          "value": "coins-receive"
        },
        {
          "text": "coins-1",
          "value": "coins-1"
        },
        {
          "text": "compass-1",
          "value": "compass-1"
        },
        {
          "text": "computer-check-lock",
          "value": "computer-check-lock"
        },
        {
          "text": "computer-desk",
          "value": "computer-desk"
        },
        {
          "text": "computer-imac-1",
          "value": "computer-imac-1"
        },
        {
          "text": "concert-rock",
          "value": "concert-rock"
        },
        {
          "text": "construction-blueprint-2",
          "value": "construction-blueprint-2"
        },
        {
          "text": "construction-shovel",
          "value": "construction-shovel"
        },
        {
          "text": "conversation-chat-bubble",
          "value": "conversation-chat-bubble"
        },
        {
          "text": "credit-card",
          "value": "credit-card"
        },
        {
          "text": "credit-card-business",
          "value": "credit-card-business"
        },
        {
          "text": "credit-card-check",
          "value": "credit-card-check"
        },
        {
          "text": "credit-card-give",
          "value": "credit-card-give"
        },
        {
          "text": "credit-card-hand",
          "value": "credit-card-hand"
        },
        {
          "text": "credit-card-laptop",
          "value": "credit-card-laptop"
        },
        {
          "text": "credit-card-lock",
          "value": "credit-card-lock"
        },
        {
          "text": "credit-card-monitor-payment-regular",
          "value": "credit-card-monitor-payment-regular"
        },
        {
          "text": "credit-card-monitor-payment-regular-2",
          "value": "credit-card-monitor-payment-regular-2"
        },
        {
          "text": "cupcake",
          "value": "cupcake"
        },
        {
          "text": "currency-dollar-increase",
          "value": "currency-dollar-increase"
        },
        {
          "text": "cursor-choose",
          "value": "cursor-choose"
        },
        {
          "text": "cursor-finger",
          "value": "cursor-finger"
        },
        {
          "text": "cursor-tap",
          "value": "cursor-tap"
        },
        {
          "text": "cursor-touch-1",
          "value": "cursor-touch-1"
        },
        {
          "text": "delivery-truck-2",
          "value": "delivery-truck-2"
        },
        {
          "text": "diamond",
          "value": "diamond"
        },
        {
          "text": "dining-set",
          "value": "dining-set"
        },
        {
          "text": "dollar-bag",
          "value": "dollar-bag"
        },
        {
          "text": "dollar-decrease",
          "value": "dollar-decrease"
        },
        {
          "text": "dollar-increase",
          "value": "dollar-increase"
        },
        {
          "text": "dollar-sign-circle",
          "value": "dollar-sign-circle"
        },
        {
          "text": "door-enter",
          "value": "door-enter"
        },
        {
          "text": "dress",
          "value": "dress"
        },
        {
          "text": "dress-1",
          "value": "dress-1"
        },
        {
          "text": "e-commerce-buy-apparel",
          "value": "e-commerce-buy-apparel"
        },
        {
          "text": "e-commerce-shopping-bag",
          "value": "e-commerce-shopping-bag"
        },
        {
          "text": "eco-globe-1",
          "value": "eco-globe-1"
        },
        {
          "text": "eco-house",
          "value": "eco-house"
        },
        {
          "text": "eco-mind",
          "value": "eco-mind"
        },
        {
          "text": "eco-nature",
          "value": "eco-nature"
        },
        {
          "text": "ecology-human-mind",
          "value": "ecology-human-mind"
        },
        {
          "text": "eiffel-tower",
          "value": "eiffel-tower"
        },
        {
          "text": "email-send-1",
          "value": "email-send-1"
        },
        {
          "text": "email-send-2",
          "value": "email-send-2"
        },
        {
          "text": "email-send-3",
          "value": "email-send-3"
        },
        {
          "text": "face-id-1",
          "value": "face-id-1"
        },
        {
          "text": "face-id-9",
          "value": "face-id-9"
        },
        {
          "text": "face-id-10",
          "value": "face-id-10"
        },
        {
          "text": "farmer",
          "value": "farmer"
        },
        {
          "text": "female",
          "value": "female"
        },
        {
          "text": "file-checklist",
          "value": "file-checklist"
        },
        {
          "text": "file-time-question",
          "value": "file-time-question"
        },
        {
          "text": "fire",
          "value": "fire"
        },
        {
          "text": "fireworks-people-watch",
          "value": "fireworks-people-watch"
        },
        {
          "text": "flag-heart",
          "value": "flag-heart"
        },
        {
          "text": "flash-1",
          "value": "flash-1"
        },
        {
          "text": "flower-7",
          "value": "flower-7"
        },
        {
          "text": "focus-face",
          "value": "focus-face"
        },
        {
          "text": "food-dome-serving-1",
          "value": "food-dome-serving-1"
        },
        {
          "text": "food-dome-serving-2",
          "value": "food-dome-serving-2"
        },
        {
          "text": "food-truck",
          "value": "food-truck"
        },
        {
          "text": "footwear-open-heels",
          "value": "footwear-open-heels"
        },
        {
          "text": "garage",
          "value": "garage"
        },
        {
          "text": "glasses-round-1",
          "value": "glasses-round-1"
        },
        {
          "text": "globe-1",
          "value": "globe-1"
        },
        {
          "text": "globe-2",
          "value": "globe-2"
        },
        {
          "text": "globe-2-locations",
          "value": "globe-2-locations"
        },
        {
          "text": "globe-3",
          "value": "globe-3"
        },
        {
          "text": "globe-favorite-heart",
          "value": "globe-favorite-heart"
        },
        {
          "text": "globe-pin",
          "value": "globe-pin"
        },
        {
          "text": "golf-player",
          "value": "golf-player"
        },
        {
          "text": "grape",
          "value": "grape"
        },
        {
          "text": "graph",
          "value": "graph"
        },
        {
          "text": "graph-bar-increase",
          "value": "graph-bar-increase"
        },
        {
          "text": "graph-bar-line",
          "value": "graph-bar-line"
        },
        {
          "text": "group-chat",
          "value": "group-chat"
        },
        {
          "text": "group-check",
          "value": "group-check"
        },
        {
          "text": "group-favorite-heart",
          "value": "group-favorite-heart"
        },
        {
          "text": "group-global",
          "value": "group-global"
        },
        {
          "text": "group-protect",
          "value": "group-protect"
        },
        {
          "text": "group-wifi",
          "value": "group-wifi"
        },
        {
          "text": "hand-diamond",
          "value": "hand-diamond"
        },
        {
          "text": "hand-remote",
          "value": "hand-remote"
        },
        {
          "text": "hand-tablet",
          "value": "hand-tablet"
        },
        {
          "text": "hat-tall",
          "value": "hat-tall"
        },
        {
          "text": "headphone-wifi",
          "value": "headphone-wifi"
        },
        {
          "text": "heart-angel",
          "value": "heart-angel"
        },
        {
          "text": "heart-balloons",
          "value": "heart-balloons"
        },
        {
          "text": "heart-care",
          "value": "heart-care"
        },
        {
          "text": "heart-edit",
          "value": "heart-edit"
        },
        {
          "text": "heart-favorite",
          "value": "heart-favorite"
        },
        {
          "text": "heart-protect",
          "value": "heart-protect"
        },
        {
          "text": "heart-refresh",
          "value": "heart-refresh"
        },
        {
          "text": "heart-search",
          "value": "heart-search"
        },
        {
          "text": "heart-share",
          "value": "heart-share"
        },
        {
          "text": "heavy-equipment-cleaner",
          "value": "heavy-equipment-cleaner"
        },
        {
          "text": "heavy-equipment-cleaner-1",
          "value": "heavy-equipment-cleaner-1"
        },
        {
          "text": "heavy-equipment-excavator",
          "value": "heavy-equipment-excavator"
        },
        {
          "text": "home-1",
          "value": "home-1"
        },
        {
          "text": "home-5",
          "value": "home-5"
        },
        {
          "text": "house-favorite-heart",
          "value": "house-favorite-heart"
        },
        {
          "text": "house-hand",
          "value": "house-hand"
        },
        {
          "text": "house-heart",
          "value": "house-heart"
        },
        {
          "text": "house-search",
          "value": "house-search"
        },
        {
          "text": "house-search-1",
          "value": "house-search-1"
        },
        {
          "text": "house-search-2",
          "value": "house-search-2"
        },
        {
          "text": "hyperlink-2",
          "value": "hyperlink-2"
        },
        {
          "text": "id-card-2",
          "value": "id-card-2"
        },
        {
          "text": "inbox-heart",
          "value": "inbox-heart"
        },
        {
          "text": "island",
          "value": "island"
        },
        {
          "text": "job-search-team-woman",
          "value": "job-search-team-woman"
        },
        {
          "text": "key-hole-2",
          "value": "key-hole-2"
        },
        {
          "text": "keyboard",
          "value": "keyboard"
        },
        {
          "text": "king",
          "value": "king"
        },
        {
          "text": "lady-2",
          "value": "lady-2"
        },
        {
          "text": "lawn-mower",
          "value": "lawn-mower"
        },
        {
          "text": "leaf",
          "value": "leaf"
        },
        {
          "text": "letter-blocks",
          "value": "letter-blocks"
        },
        {
          "text": "lightbulb-4",
          "value": "lightbulb-4"
        },
        {
          "text": "like-shine",
          "value": "like-shine"
        },
        {
          "text": "link-1",
          "value": "link-1"
        },
        {
          "text": "list-numbers",
          "value": "list-numbers"
        },
        {
          "text": "location-computer",
          "value": "location-computer"
        },
        {
          "text": "location-map",
          "value": "location-map"
        },
        {
          "text": "location-pin-1",
          "value": "location-pin-1"
        },
        {
          "text": "location-pin-2",
          "value": "location-pin-2"
        },
        {
          "text": "location-pin-airport-1",
          "value": "location-pin-airport-1"
        },
        {
          "text": "location-pin-dining-1",
          "value": "location-pin-dining-1"
        },
        {
          "text": "location-pin-direction-1",
          "value": "location-pin-direction-1"
        },
        {
          "text": "location-pin-direction-3",
          "value": "location-pin-direction-3"
        },
        {
          "text": "location-pin-exclamation-1",
          "value": "location-pin-exclamation-1"
        },
        {
          "text": "location-pin-exclamation-2",
          "value": "location-pin-exclamation-2"
        },
        {
          "text": "location-pin-favorite-2",
          "value": "location-pin-favorite-2"
        },
        {
          "text": "location-pin-group",
          "value": "location-pin-group"
        },
        {
          "text": "location-pins",
          "value": "location-pins"
        },
        {
          "text": "location-user",
          "value": "location-user"
        },
        {
          "text": "lock-close-1",
          "value": "lock-close-1"
        },
        {
          "text": "lock-shield",
          "value": "lock-shield"
        },
        {
          "text": "login-key",
          "value": "login-key"
        },
        {
          "text": "login-key-light",
          "value": "login-key-light"
        },
        {
          "text": "long-sleeve-t-shirt",
          "value": "long-sleeve-t-shirt"
        },
        {
          "text": "love-gift-diamond",
          "value": "love-gift-diamond"
        },
        {
          "text": "love-it-angel",
          "value": "love-it-angel"
        },
        {
          "text": "macro-mode",
          "value": "macro-mode"
        },
        {
          "text": "map-mountain-forest",
          "value": "map-mountain-forest"
        },
        {
          "text": "map-pin-1",
          "value": "map-pin-1"
        },
        {
          "text": "map-search",
          "value": "map-search"
        },
        {
          "text": "map-treasure",
          "value": "map-treasure"
        },
        {
          "text": "mask-double",
          "value": "mask-double"
        },
        {
          "text": "mask-happy",
          "value": "mask-happy"
        },
        {
          "text": "meeting-smartphone-hold",
          "value": "meeting-smartphone-hold"
        },
        {
          "text": "megaphone-2",
          "value": "megaphone-2"
        },
        {
          "text": "messages-people-user-heart",
          "value": "messages-people-user-heart"
        },
        {
          "text": "microphone-4",
          "value": "microphone-4"
        },
        {
          "text": "mobile-phone-check",
          "value": "mobile-phone-check"
        },
        {
          "text": "mobile-phone-credit-card",
          "value": "mobile-phone-credit-card"
        },
        {
          "text": "mobile-phone-view-2",
          "value": "mobile-phone-view-2"
        },
        {
          "text": "modern-music-bass-guitar",
          "value": "modern-music-bass-guitar"
        },
        {
          "text": "money-bag-dollar",
          "value": "money-bag-dollar"
        },
        {
          "text": "mood-happy-laptop",
          "value": "mood-happy-laptop"
        },
        {
          "text": "moutache-monocle",
          "value": "moutache-monocle"
        },
        {
          "text": "mount-fuji",
          "value": "mount-fuji"
        },
        {
          "text": "mouse",
          "value": "mouse"
        },
        {
          "text": "multiple-actions-location",
          "value": "multiple-actions-location"
        },
        {
          "text": "multiple-actions-view",
          "value": "multiple-actions-view"
        },
        {
          "text": "music-note-1",
          "value": "music-note-1"
        },
        {
          "text": "nautic-sports-surfing",
          "value": "nautic-sports-surfing"
        },
        {
          "text": "nautic-sports-surfing-water",
          "value": "nautic-sports-surfing-water"
        },
        {
          "text": "network-cash",
          "value": "network-cash"
        },
        {
          "text": "network-computers-1",
          "value": "network-computers-1"
        },
        {
          "text": "network-people",
          "value": "network-people"
        },
        {
          "text": "network-search",
          "value": "network-search"
        },
        {
          "text": "network-share",
          "value": "network-share"
        },
        {
          "text": "network-user",
          "value": "network-user"
        },
        {
          "text": "noodle-bowl",
          "value": "noodle-bowl"
        },
        {
          "text": "notebook-pencil",
          "value": "notebook-pencil"
        },
        {
          "text": "notebook-user",
          "value": "notebook-user"
        },
        {
          "text": "notes-check",
          "value": "notes-check"
        },
        {
          "text": "old-people-man-2",
          "value": "old-people-man-2"
        },
        {
          "text": "paper-write",
          "value": "paper-write"
        },
        {
          "text": "party-balloons",
          "value": "party-balloons"
        },
        {
          "text": "party-mask",
          "value": "party-mask"
        },
        {
          "text": "party-popper",
          "value": "party-popper"
        },
        {
          "text": "password-desktop-approved",
          "value": "password-desktop-approved"
        },
        {
          "text": "password-desktop-lock-approved",
          "value": "password-desktop-lock-approved"
        },
        {
          "text": "pear",
          "value": "pear"
        },
        {
          "text": "pen-write-2",
          "value": "pen-write-2"
        },
        {
          "text": "pencil-circle",
          "value": "pencil-circle"
        },
        {
          "text": "pencil-write",
          "value": "pencil-write"
        },
        {
          "text": "people-man-1",
          "value": "people-man-1"
        },
        {
          "text": "people-man-3",
          "value": "people-man-3"
        },
        {
          "text": "people-woman-1",
          "value": "people-woman-1"
        },
        {
          "text": "pencil-write-1",
          "value": "pencil-write-1"
        },
        {
          "text": "person-add-1",
          "value": "person-add-1"
        },
        {
          "text": "person-check-1",
          "value": "person-check-1"
        },
        {
          "text": "person-check-2",
          "value": "person-check-2"
        },
        {
          "text": "person-setting-2",
          "value": "person-setting-2"
        },
        {
          "text": "person-view-2",
          "value": "person-view-2"
        },
        {
          "text": "pet-dog-walk",
          "value": "pet-dog-walk"
        },
        {
          "text": "pet-love",
          "value": "pet-love"
        },
        {
          "text": "pet-paw",
          "value": "pet-paw"
        },
        {
          "text": "pet-search",
          "value": "pet-search"
        },
        {
          "text": "phone-2",
          "value": "phone-2"
        },
        {
          "text": "piano",
          "value": "piano"
        },
        {
          "text": "picture-3",
          "value": "picture-3"
        },
        {
          "text": "pie",
          "value": "pie"
        },
        {
          "text": "piggy-bank",
          "value": "piggy-bank"
        },
        {
          "text": "piggy-bank-2",
          "value": "piggy-bank-2"
        },
        {
          "text": "pin-1",
          "value": "pin-1"
        },
        {
          "text": "plane-boarding-pass-hand",
          "value": "plane-boarding-pass-hand"
        },
        {
          "text": "police-cap",
          "value": "police-cap"
        },
        {
          "text": "police-officer",
          "value": "police-officer"
        },
        {
          "text": "price-tag",
          "value": "price-tag"
        },
        {
          "text": "quill",
          "value": "quill"
        },
        {
          "text": "quill-write",
          "value": "quill-write"
        },
        {
          "text": "radio-1",
          "value": "radio-1"
        },
        {
          "text": "radio-3",
          "value": "radio-3"
        },
        {
          "text": "raft-boat",
          "value": "raft-boat"
        },
        {
          "text": "rank-army-badge-1",
          "value": "rank-army-badge-1"
        },
        {
          "text": "rank-army-star-2",
          "value": "rank-army-star-2"
        },
        {
          "text": "rating-star",
          "value": "rating-star"
        },
        {
          "text": "rating-star-give",
          "value": "rating-star-give"
        },
        {
          "text": "real-estate-action-building-search",
          "value": "real-estate-action-building-search"
        },
        {
          "text": "real-estate-house-person",
          "value": "real-estate-house-person"
        },
        {
          "text": "real-estate-person-search-house",
          "value": "real-estate-person-search-house"
        },
        {
          "text": "real-estate-search-house",
          "value": "real-estate-search-house"
        },
        {
          "text": "recycling-sign",
          "value": "recycling-sign"
        },
        {
          "text": "restaurant-dishes",
          "value": "restaurant-dishes"
        },
        {
          "text": "road-pin",
          "value": "road-pin"
        },
        {
          "text": "road-straight",
          "value": "road-straight"
        },
        {
          "text": "rocket",
          "value": "rocket"
        },
        {
          "text": "rolling-pin",
          "value": "rolling-pin"
        },
        {
          "text": "saving-piggy-dollars",
          "value": "saving-piggy-dollars"
        },
        {
          "text": "school-grade-a",
          "value": "school-grade-a"
        },
        {
          "text": "school-graduation",
          "value": "school-graduation"
        },
        {
          "text": "school-teacher-art",
          "value": "school-teacher-art"
        },
        {
          "text": "school-test-art",
          "value": "school-test-art"
        },
        {
          "text": "scooter-3",
          "value": "scooter-3"
        },
        {
          "text": "search",
          "value": "search"
        },
        {
          "text": "search-square",
          "value": "search-square"
        },
        {
          "text": "server-add-2",
          "value": "server-add-2"
        },
        {
          "text": "server-check-2",
          "value": "server-check-2"
        },
        {
          "text": "settings-human",
          "value": "settings-human"
        },
        {
          "text": "share",
          "value": "share"
        },
        {
          "text": "share-location",
          "value": "share-location"
        },
        {
          "text": "share-religion-eye-2",
          "value": "share-religion-eye-2"
        },
        {
          "text": "share-setting",
          "value": "share-setting"
        },
        {
          "text": "sherif-star",
          "value": "sherif-star"
        },
        {
          "text": "shield-1",
          "value": "shield-1"
        },
        {
          "text": "shield-6",
          "value": "shield-6"
        },
        {
          "text": "shipment-in-transit",
          "value": "shipment-in-transit"
        },
        {
          "text": "shop-like",
          "value": "shop-like"
        },
        {
          "text": "shop-sign-open",
          "value": "shop-sign-open"
        },
        {
          "text": "shopping-bag-check",
          "value": "shopping-bag-check"
        },
        {
          "text": "shopping-basket-search",
          "value": "shopping-basket-search"
        },
        {
          "text": "shopping-cart-1",
          "value": "shopping-cart-1"
        },
        {
          "text": "shopping-cart-2",
          "value": "shopping-cart-2"
        },
        {
          "text": "shopping-cart-4",
          "value": "shopping-cart-4"
        },
        {
          "text": "shopping-cart-check",
          "value": "shopping-cart-check"
        },
        {
          "text": "shopping-cart-checkout-2",
          "value": "shopping-cart-checkout-2"
        },
        {
          "text": "shopping-cart-download-1",
          "value": "shopping-cart-download-1"
        },
        {
          "text": "shopping-cart-full",
          "value": "shopping-cart-full"
        },
        {
          "text": "shopping-cart-favorite-heart-2",
          "value": "shopping-cart-favorite-heart-2"
        },
        {
          "text": "shopping-cart-search",
          "value": "shopping-cart-search"
        },
        {
          "text": "sign-for-sale-2",
          "value": "sign-for-sale-2"
        },
        {
          "text": "sign-recycle",
          "value": "sign-recycle"
        },
        {
          "text": "sign-sold-2",
          "value": "sign-sold-2"
        },
        {
          "text": "sign-wanted",
          "value": "sign-wanted"
        },
        {
          "text": "signal-tower",
          "value": "signal-tower"
        },
        {
          "text": "single-man-search",
          "value": "single-man-search"
        },
        {
          "text": "single-neutral-actions-laptop",
          "value": "single-neutral-actions-laptop"
        },
        {
          "text": "single-neutral-actions-share-2",
          "value": "single-neutral-actions-share-2"
        },
        {
          "text": "single-neutral-actions-view",
          "value": "single-neutral-actions-view"
        },
        {
          "text": "single-neutral-shield",
          "value": "single-neutral-shield"
        },
        {
          "text": "skateboard-person",
          "value": "skateboard-person"
        },
        {
          "text": "skiing-cross-country",
          "value": "skiing-cross-country"
        },
        {
          "text": "smiley-cheeky",
          "value": "smiley-cheeky"
        },
        {
          "text": "smiley-frown-2",
          "value": "smiley-frown-2"
        },
        {
          "text": "smiley-love",
          "value": "smiley-love"
        },
        {
          "text": "smiley-smile-1",
          "value": "smiley-smile-1"
        },
        {
          "text": "smiley-smile-2",
          "value": "smiley-smile-2"
        },
        {
          "text": "smiley-smile-3",
          "value": "smiley-smile-3"
        },
        {
          "text": "smiley-smile-4",
          "value": "smiley-smile-4"
        },
        {
          "text": "smiley-smile-5",
          "value": "smiley-smile-5"
        },
        {
          "text": "sport-player",
          "value": "sport-player"
        },
        {
          "text": "store",
          "value": "store"
        },
        {
          "text": "store-open",
          "value": "store-open"
        },
        {
          "text": "store-sale",
          "value": "store-sale"
        },
        {
          "text": "strawberry",
          "value": "strawberry"
        },
        {
          "text": "study-owl",
          "value": "study-owl"
        },
        {
          "text": "sunny",
          "value": "sunny"
        },
        {
          "text": "synchronize-arrows-three",
          "value": "synchronize-arrows-three"
        },
        {
          "text": "taking-pictures-woman-1",
          "value": "taking-pictures-woman-1"
        },
        {
          "text": "tap-check",
          "value": "tap-check"
        },
        {
          "text": "task-check-2",
          "value": "task-check-2"
        },
        {
          "text": "task-checklist",
          "value": "task-checklist"
        },
        {
          "text": "task-checklist-check",
          "value": "task-checklist-check"
        },
        {
          "text": "task-edit",
          "value": "task-edit"
        },
        {
          "text": "task-list-pen",
          "value": "task-list-pen"
        },
        {
          "text": "task-timeout",
          "value": "task-timeout"
        },
        {
          "text": "team-chat",
          "value": "team-chat"
        },
        {
          "text": "team-idea",
          "value": "team-idea"
        },
        {
          "text": "tent",
          "value": "tent"
        },
        {
          "text": "thumbs-up-1",
          "value": "thumbs-up-1"
        },
        {
          "text": "thumbs-up-2",
          "value": "thumbs-up-2"
        },
        {
          "text": "ticket-3",
          "value": "ticket-3"
        },
        {
          "text": "toolbox",
          "value": "toolbox"
        },
        {
          "text": "tools-driller",
          "value": "tools-driller"
        },
        {
          "text": "taking-pictures-human",
          "value": "taking-pictures-human"
        },
        {
          "text": "tools-wrench-screwdriver",
          "value": "tools-wrench-screwdriver"
        },
        {
          "text": "transfer-arrows",
          "value": "transfer-arrows"
        },
        {
          "text": "transfer-pictures-laptop",
          "value": "transfer-pictures-laptop"
        },
        {
          "text": "travel-bag-1",
          "value": "travel-bag-1"
        },
        {
          "text": "travel-bag-2",
          "value": "travel-bag-2"
        },
        {
          "text": "trekking-person",
          "value": "trekking-person"
        },
        {
          "text": "truck-1",
          "value": "truck-1"
        },
        {
          "text": "truck-2",
          "value": "truck-2"
        },
        {
          "text": "truck-cargo",
          "value": "truck-cargo"
        },
        {
          "text": "truck-delivery-time",
          "value": "truck-delivery-time"
        },
        {
          "text": "truck-rv",
          "value": "truck-rv"
        },
        {
          "text": "truck-tow",
          "value": "truck-tow"
        },
        {
          "text": "typewriter-1",
          "value": "typewriter-1"
        },
        {
          "text": "user-chat-6",
          "value": "user-chat-6"
        },
        {
          "text": "user-chat-check",
          "value": "user-chat-check"
        },
        {
          "text": "user-chat-dollar",
          "value": "user-chat-dollar"
        },
        {
          "text": "van",
          "value": "van"
        },
        {
          "text": "view-1",
          "value": "view-1"
        },
        {
          "text": "wallet-3",
          "value": "wallet-3"
        },
        {
          "text": "warehouse-storage",
          "value": "warehouse-storage"
        },
        {
          "text": "watering-can",
          "value": "watering-can"
        },
        {
          "text": "whale-heart",
          "value": "whale-heart"
        },
        {
          "text": "wifi-heart",
          "value": "wifi-heart"
        },
        {
          "text": "window-application-5",
          "value": "window-application-5"
        },
        {
          "text": "window-password",
          "value": "window-password"
        },
        {
          "text": "window-search",
          "value": "window-search"
        },
        {
          "text": "wine-sparkling-cheers",
          "value": "wine-sparkling-cheers"
        },
        {
          "text": "wireless-payment-credit-card",
          "value": "wireless-payment-credit-card"
        },
        {
          "text": "world-flight",
          "value": "world-flight"
        },
        {
          "text": "horses-morzillo",
          "value": "horses-morzillo"
        },
        {
          "text": "tack-morzillo",
          "value": "tack-morzillo"
        },
        {
          "text": "venue-morzillo",
          "value": "venue-morzillo"
        }
      ];
      
      function getIcons(){
          return icons;
      }

    module.lpIcons = {
        getIcons: getIcons
    };
})(window.ST);
