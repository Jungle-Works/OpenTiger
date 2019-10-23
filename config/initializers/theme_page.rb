module ThemePage
  # rubocop:disable Metrics/ModuleLength
  module StaticData

    # TODO Document the expected JSON structure here

    DATA_STR = <<JSON
{
  "screenshots": [
    {
      "id": "single_info_without_cta",
      "kind": "info",
      "variation": "single_column",
      "title": "Single column info section without call to action button",
      "paragraph": "This is a single column info section without background image and call to action button.",
      "background_image": {"src": "https://yelodotred.s3.amazonaws.com/task_images/69oE1561101416063-defaultlpbg.jpg"}
    },
  ]
}
JSON


  end
  # rubocop:enable Metrics/ModuleLength
end
