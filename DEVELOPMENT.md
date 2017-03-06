# Development

- ResourcefulResponseBuilder
  - implement messages
    - "Successfully actioned resource"
    - "Unable to action resource"
  - support API responses
- ResourcesController
  - ::resource :only, :except, :api, :views - filter actions
- Responders
  - RenderViewResponder: pass messages to flash
  - JsonResponder: builds a JSON api response
